import {BetaAnalyticsDataClient} from "@google-analytics/data";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {assertAdmin, parseDatabaseId} from "./assertAdmin";
import {dbForDatabaseId} from "../firestore";
import {getPlannedCase, listPlannedCaseDateIds} from "../localCaseCatalog";
import {todayUtcDateId} from "../utils/dateId";

interface OperationalMetricsRequest {
  days?: number;
  databaseId?: string;
}

function daysAgoDateId(days: number): string {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - days);
  return d.toISOString().slice(0, 10);
}

export const adminGetOperationalMetrics = onCall(async (request) => {
  assertAdmin(request);
  const data = (request.data ?? {}) as OperationalMetricsRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const days = Math.min(Math.max(data.days ?? 7, 1), 90);
  const db = dbForDatabaseId(databaseId);

  const usersSnap = await db.collection("userGameStates").get();
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);

  let totalUsers = 0;
  let activeUsers = 0;
  let blockedUsers = 0;
  let totalCompletedGames = 0;
  let totalDetectivePoints = 0;

  for (const doc of usersSnap.docs) {
    totalUsers++;
    const d = doc.data();
    if (d.blockedAt) blockedUsers++;
    totalCompletedGames += (d.completedGames as number) ?? 0;
    totalDetectivePoints += (d.detectivePoints as number) ?? 0;

    const updated = d.updatedDate?.toDate?.() as Date | undefined;
    if (updated && updated >= cutoff) {
      activeUsers++;
    }
  }

  const todayUtc = todayUtcDateId();
  const todayLocal = new Date().toISOString().slice(0, 10);

  const todayGame = await db.collection("games").doc(todayLocal).get();
  const todayCase = await db.collection("detectiveCases").doc(todayUtc).get();

  const plannedIds = listPlannedCaseDateIds();
  const missingPlanned: string[] = [];
  for (const dateId of plannedIds.slice(0, 14)) {
    if (dateId < todayUtc) continue;
    const caseDoc = await db.collection("detectiveCases").doc(dateId).get();
    if (!caseDoc.exists && getPlannedCase(dateId)) {
      missingPlanned.push(dateId);
    }
  }

  const dailyActiveTrend: Array<{dateId: string; activeUsers: number}> = [];
  for (let i = days - 1; i >= 0; i--) {
    const dateId = daysAgoDateId(i);
    let count = 0;
    for (const doc of usersSnap.docs) {
      const updated = doc.data().updatedDate?.toDate?.() as Date | undefined;
      if (!updated) continue;
      if (updated.toISOString().slice(0, 10) === dateId) {
        count++;
      }
    }
    dailyActiveTrend.push({dateId, activeUsers: count});
  }

  return {
    days,
    totalUsers,
    activeUsers,
    blockedUsers,
    totalCompletedGames,
    totalDetectivePoints,
    contentHealth: {
      todayGameExists: todayGame.exists,
      todayCaseExists: todayCase.exists,
      todayGameDateId: todayLocal,
      todayCaseDateId: todayUtc,
      missingPlannedCasesNext14Days: missingPlanned,
    },
    dailyActiveTrend,
  };
});

interface Ga4MetricsRequest {
  days?: number;
}

export const adminGetGa4Metrics = onCall(async (request) => {
  assertAdmin(request);
  const data = (request.data ?? {}) as Ga4MetricsRequest;
  const days = Math.min(Math.max(data.days ?? 7, 1), 30);

  const propertyId = process.env.GA4_PROPERTY_ID?.trim();
  if (!propertyId) {
    return {
      configured: false,
      message: "GA4_PROPERTY_ID secret is not configured",
      days,
      metrics: null,
    };
  }

  try {
    const client = new BetaAnalyticsDataClient();

    const [report] = await client.runReport({
      property: `properties/${propertyId}`,
      dateRanges: [{startDate: `${days}daysAgo`, endDate: "today"}],
      metrics: [
        {name: "activeUsers"},
        {name: "eventCount"},
      ],
      dimensions: [{name: "date"}],
    });

    const daily: Array<{date: string; activeUsers: number; eventCount: number}> = [];
    for (const row of report.rows ?? []) {
      daily.push({
        date: row.dimensionValues?.[0]?.value ?? "",
        activeUsers: Number(row.metricValues?.[0]?.value ?? 0),
        eventCount: Number(row.metricValues?.[1]?.value ?? 0),
      });
    }

    const [eventsReport] = await client.runReport({
      property: `properties/${propertyId}`,
      dateRanges: [{startDate: `${days}daysAgo`, endDate: "today"}],
      metrics: [{name: "eventCount"}],
      dimensions: [{name: "eventName"}],
      limit: 10,
      orderBys: [{metric: {metricName: "eventCount"}, desc: true}],
    });

    const topEvents: Array<{eventName: string; count: number}> = [];
    for (const row of eventsReport.rows ?? []) {
      topEvents.push({
        eventName: row.dimensionValues?.[0]?.value ?? "",
        count: Number(row.metricValues?.[0]?.value ?? 0),
      });
    }

    return {
      configured: true,
      days,
      daily,
      topEvents,
      consoleUrl: `https://analytics.google.com/analytics/web/#/p${propertyId}/reports/intelligenthome`,
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    throw new HttpsError(
      "failed-precondition",
      `GA4 query failed: ${message}. Ensure Analytics Data API is enabled and the service account has access.`,
    );
  }
});
