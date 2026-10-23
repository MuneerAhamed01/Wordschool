#!/usr/bin/env python3
"""Scaffold a Kerala PSC app Cloud Function (TypeScript, firebase-functions v2).

Needs the shared helpers from task CW-007: src/firestore.ts (db), src/admin/assertAdmin.ts,
src/admin/auditLog.ts.

Kinds:
  admin-callable   onCall + assertAdmin + writeAuditLog
  player-callable  onCall for signed-in, non-blocked players
  scheduled        onSchedule with Asia/Kolkata timezone
  trigger          onDocumentWritten on a document path

Creates (never overwrites unless --force):
  functions/src/<dir>/<name>.ts           the function (thin: parse → validate → write)
  functions/src/<dir>/<name>.logic.ts     pure logic (validation / calculation), no Firestore
  functions/src/<dir>/<name>.logic.test.ts Jest tests for the pure logic

Then prints the export line for functions/src/index.ts.

Example:
  python3 .claude/skills/cloud-function/scripts/scaffold_function.py \
      --name adminSaveCategory --kind admin-callable --dir crossword
"""

from __future__ import annotations

import argparse
import os
import re
import sys

REGION = "asia-south1"


def import_prefix(dir_: str) -> str:
    depth = len([p for p in dir_.split("/") if p])
    return "../" * depth if depth else "./"


def logic_ts(name: str, kind: str) -> str:
    cap = name[:1].upper() + name[1:]
    if kind in ("admin-callable", "player-callable"):
        return f'''/**
 * Pure logic for `{name}`. No Firestore or firebase-functions imports here,
 * so everything in this file is unit-tested in `{name}.logic.test.ts`.
 */

export interface {cap}Input {{
  // TODO: request fields
  id: string;
}}

export class {cap}ValidationError extends Error {{
  /**
   * @param {{string[]}} problems Every problem found, so the caller can fix all at once.
   */
  constructor(public readonly problems: string[]) {{
    super(problems.join("; "));
    this.name = "{cap}ValidationError";
  }}
}}

/**
 * Validates and normalizes the raw request payload.
 * @param {{unknown}} raw Request data from the client.
 * @return {{{cap}Input}} A clean, typed input.
 */
export function parse{cap}Input(raw: unknown): {cap}Input {{
  const data = (raw ?? {{}}) as Record<string, unknown>;
  const problems: string[] = [];

  const id = typeof data.id === "string" ? data.id.trim() : "";
  if (!/^[a-z0-9-]{{1,80}}$/.test(id)) {{
    problems.push("id must be lowercase letters, digits or '-' (1-80 chars)");
  }}

  if (problems.length > 0) {{
    throw new {cap}ValidationError(problems);
  }}
  return {{id}};
}}
'''
    return f'''/**
 * Pure logic for `{name}`. No Firestore or firebase-functions imports here.
 */

/**
 * Decides what the job should act on. Keep it pure so it is easy to test.
 * @param {{Date}} now Current time.
 * @return {{string}} TODO: replace with the real decision.
 */
export function plan{cap}(now: Date): string {{
  return now.toISOString().slice(0, 10);
}}
'''


def logic_test_ts(name: str, kind: str) -> str:
    cap = name[:1].upper() + name[1:]
    if kind in ("admin-callable", "player-callable"):
        return f'''import {{parse{cap}Input, {cap}ValidationError}} from "./{name}.logic";

describe("parse{cap}Input", () => {{
  it("accepts a valid payload", () => {{
    expect(parse{cap}Input({{id: "kerala-history"}})).toEqual({{id: "kerala-history"}});
  }});

  it("trims the id", () => {{
    expect(parse{cap}Input({{id: "  kerala-history "}}).id).toBe("kerala-history");
  }});

  it("rejects a bad id with a readable message", () => {{
    expect(() => parse{cap}Input({{id: "Kerala History"}})).toThrow({cap}ValidationError);
  }});

  it("rejects a missing payload", () => {{
    expect(() => parse{cap}Input(undefined)).toThrow({cap}ValidationError);
  }});
}});
'''
    return f'''import {{plan{cap}}} from "./{name}.logic";

describe("plan{cap}", () => {{
  it("returns the date id for now", () => {{
    expect(plan{cap}(new Date("2026-10-22T00:00:00Z"))).toBe("2026-10-22");
  }});
}});
'''


def handler_ts(name: str, kind: str, dir_: str, schedule: str, doc_path: str) -> str:
    cap = name[:1].upper() + name[1:]
    up = import_prefix(dir_)
    if kind == "admin-callable":
        return f'''import {{onCall, HttpsError}} from "firebase-functions/v2/https";
import {{FieldValue}} from "firebase-admin/firestore";
import {{assertAdmin}} from "{up}admin/assertAdmin";
import {{writeAuditLog}} from "{up}admin/auditLog";
import {{db}} from "{up}firestore";
import {{parse{cap}Input, {cap}ValidationError}} from "./{name}.logic";

/**
 * Admin callable: TODO one line on what it changes.
 * Request: {{ id, ... }}  Response: {{ id, status }}
 */
export const {name} = onCall({{region: "{REGION}"}}, async (request) => {{
  const adminUid = assertAdmin(request);

  let input;
  try {{
    input = parse{cap}Input(request.data);
  }} catch (error) {{
    if (error instanceof {cap}ValidationError) {{
      throw new HttpsError("invalid-argument", error.message, {{problems: error.problems}});
    }}
    throw error;
  }}

  // TODO: replace with the real collection constant from ./collections
  const ref = db().collection("TODO_COLLECTION").doc(input.id);
  const batch = db().batch();
  batch.set(ref, {{
    ...input,
    updatedAt: FieldValue.serverTimestamp(),
    updatedBy: adminUid,
  }}, {{merge: true}});
  await batch.commit();

  await writeAuditLog({{
    action: "{dir_ or "admin"}.{name}",
    adminUid,
    targetId: input.id,
    payload: {{...input}},
  }});

  return {{id: input.id, status: "saved"}};
}});
'''
    if kind == "player-callable":
        return f'''import {{onCall, HttpsError}} from "firebase-functions/v2/https";
import {{db}} from "{up}firestore";
import {{parse{cap}Input, {cap}ValidationError}} from "./{name}.logic";

/**
 * Player callable: TODO one line on what it does. Must be idempotent.
 */
export const {name} = onCall({{region: "{REGION}"}}, async (request) => {{
  const uid = request.auth?.uid;
  if (!uid) {{
    throw new HttpsError("unauthenticated", "Sign in required");
  }}

  const userSnap = await db().collection("users").doc(uid).get();
  if (userSnap.get("blockedAt") != null) {{
    throw new HttpsError("permission-denied", "Account is blocked");
  }}

  let input;
  try {{
    input = parse{cap}Input(request.data);
  }} catch (error) {{
    if (error instanceof {cap}ValidationError) {{
      throw new HttpsError("invalid-argument", error.message, {{problems: error.problems}});
    }}
    throw error;
  }}

  // TODO: read what you need, compute with pure functions from the .logic file,
  // then write everything in one batch or transaction.
  return {{id: input.id}};
}});
'''
    if kind == "scheduled":
        return f'''import {{onSchedule}} from "firebase-functions/v2/scheduler";
import {{logger}} from "firebase-functions/v2";
import {{db}} from "{up}firestore";
import {{plan{cap}}} from "./{name}.logic";

/**
 * Scheduled job: TODO one line on what it does.
 */
export const {name} = onSchedule(
  {{schedule: "{schedule}", timeZone: "Asia/Kolkata", region: "{REGION}"}},
  async () => {{
    const target = plan{cap}(new Date());
    logger.info("{name} running", {{target}});
    // TODO: query with a limit, write in a batch. Keep reads bounded.
    void db;
  }},
);
'''
    # trigger
    return f'''import {{onDocumentWritten}} from "firebase-functions/v2/firestore";
import {{logger}} from "firebase-functions/v2";
import {{plan{cap}}} from "./{name}.logic";

/**
 * Trigger: TODO one line. Return early when nothing relevant changed.
 */
export const {name} = onDocumentWritten(
  {{document: "{doc_path}", region: "{REGION}"}},
  async (event) => {{
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!after) {{
      return;
    }}
    logger.info("{name}", {{params: event.params, changed: before !== after}});
    void plan{cap}(new Date());
  }},
);
'''


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=".", help="repo root (default: cwd)")
    ap.add_argument("--name", required=True, help="camelCase export name, e.g. adminSaveCategory")
    ap.add_argument("--kind", required=True,
                    choices=["admin-callable", "player-callable", "scheduled", "trigger"])
    ap.add_argument("--dir", default="crossword", help="folder under functions/src")
    ap.add_argument("--schedule", default="5 0 * * *", help="cron for --kind scheduled")
    ap.add_argument("--doc", default="users/{uid}/crosswordProgress/{puzzleId}",
                    help="document path for --kind trigger")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()

    if not re.fullmatch(r"[a-z][A-Za-z0-9]+", a.name):
        sys.exit("--name must be camelCase")
    if a.kind == "admin-callable" and not a.name.startswith("admin"):
        sys.exit("admin callables must start with 'admin' (repo convention)")
    if not re.fullmatch(r"[a-zA-Z0-9_/]*", a.dir):
        sys.exit("--dir must be a simple relative folder")

    src = os.path.join(a.root, "functions", "src")
    if not os.path.isdir(src):
        sys.exit(f"No functions/src under {os.path.abspath(a.root)}")
    out_dir = os.path.join(src, a.dir)
    files = {
        f"{a.name}.ts": handler_ts(a.name, a.kind, a.dir, a.schedule, a.doc),
        f"{a.name}.logic.ts": logic_ts(a.name, a.kind),
        f"{a.name}.logic.test.ts": logic_test_ts(a.name, a.kind),
    }
    os.makedirs(out_dir, exist_ok=True)
    for fname, content in files.items():
        path = os.path.join(out_dir, fname)
        rel = os.path.relpath(path, a.root)
        if os.path.exists(path) and not a.force:
            print("  = exists, skipped:", rel)
            continue
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(content)
        print("  +", rel)

    print(f'''
--- functions/src/index.ts ---
export {{{a.name}}} from "./{a.dir + "/" if a.dir else ""}{a.name}";

Next: fill the TODOs, then
  cd functions && npm run lint && npm run build && npm test''')


if __name__ == "__main__":
    main()
