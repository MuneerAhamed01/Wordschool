import * as fs from "fs";
import * as path from "path";
import {DetectiveCasePayload} from "./types/detectiveCase";
import {validateCase} from "./validation/validateCase";

interface PlannedCasesFile {
  version: number;
  startDate: string;
  cases: Array<DetectiveCasePayload & {dateId: string}>;
}

let catalogByDate: Map<string, DetectiveCasePayload> | null = null;

function resolvePlannedCasesPath(): string {
  const candidates = [
    path.resolve(__dirname, "data/planned-cases.json"),
    path.resolve(__dirname, "../src/data/planned-cases.json"),
    path.resolve(process.cwd(), "src/data/planned-cases.json"),
    path.resolve(process.cwd(), "lib/data/planned-cases.json"),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  throw new Error(
    "Could not locate planned-cases.json. Expected under functions/src/data/.",
  );
}

function loadCatalog(): Map<string, DetectiveCasePayload> {
  if (catalogByDate) {
    return catalogByDate;
  }

  const filePath = resolvePlannedCasesPath();
  const raw = JSON.parse(fs.readFileSync(filePath, "utf8")) as PlannedCasesFile;

  catalogByDate = new Map();
  for (const entry of raw.cases) {
    const {dateId, ...caseFields} = entry;
    catalogByDate.set(dateId, validateCase({...caseFields, id: dateId}));
  }

  return catalogByDate;
}

export function getPlannedCase(dateId: string): DetectiveCasePayload | null {
  return loadCatalog().get(dateId) ?? null;
}

export function listPlannedCaseDateIds(): string[] {
  return [...loadCatalog().keys()].sort();
}

export function resetPlannedCaseCatalogForTests(): void {
  catalogByDate = null;
}
