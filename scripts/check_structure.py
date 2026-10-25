#!/usr/bin/env python3
"""Structure rules for lib/ (CLAUDE.md "Code structure rules").

Prints one line per problem and exits 1 if there are any:
  * a file over 700 lines (generated files excepted)
  * a function or method that returns a widget but isn't `build` or `_build…`
  * a module importing another module or feature (only its own folder, its
    feature's `shared/`, and lib/{core,config,shared} are allowed)
  * a file name that repeats its feature inside a module
    (`crossword/home/…/crossword_x.dart`) or its folder kind
    (`models/x_model.dart`); a one-module feature (`auth/`, `game/`) keeps
    `<feature>_repository.dart`
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"
MAX_LINES = 700
GENERATED = (".freezed.dart", ".g.dart")
SKIP = {"lib/firebase_options.dart"}
# Composition roots wire everything together and may import any module.
ROOTS = {"lib/di.dart", "lib/di_admin.dart", "lib/main.dart", "lib/main_admin.dart"}
LAYERS = {"data", "domain", "presentation"}

widget_fn = re.compile(
    r"^\s*(?:static\s+)?(?:Widget\??|List<Widget>|PreferredSizeWidget)\s+(\w+)\s*\(", re.M
)
import_re = re.compile(r"^(?:import|export)\s+'package:wordshool/([^']+)'", re.M)


def module_of(rel: str) -> tuple[str, str] | None:
    """(feature, module) for a lib/features file; module '' = feature root."""
    parts = rel.split("/")
    if len(parts) < 4 or parts[1] != "features":
        return None
    feature = parts[2]
    # A feature with data/domain/presentation directly is one module.
    if any((LIB / "features" / feature / layer).is_dir() for layer in LAYERS):
        return feature, feature
    return feature, parts[3] if len(parts) > 4 else ""


def check_imports(rel: str, text: str) -> list[str]:
    own = module_of(rel)
    problems = []
    if own is None or rel in ROOTS or own[1] == "":
        return problems  # core/shared/config, or a feature's own di.dart
    for target in import_re.findall(text):
        target_rel = "lib/" + target
        other = module_of(target_rel)
        if other is None or other[1] == "":
            continue  # core, config, shared, di — always fine
        if other == own:
            continue
        if other[0] == own[0] and other[1] == "shared":
            continue
        problems.append(f"{rel}: imports another module: {target}")
    return problems


def check_names(rel: str) -> list[str]:
    parts = rel.split("/")
    name = parts[-1]
    problems = []
    own = module_of(rel)
    if own is not None and own[1] not in ("", own[0]):
        feature = own[0]
        if name.startswith(feature + "_"):
            problems.append(f"{rel}: file name repeats the feature ('{feature}_')")
    if "models" in parts and name.endswith("_model.dart"):
        problems.append(f"{rel}: file name repeats the folder ('_model')")
    return problems


def main() -> int:
    problems: list[str] = []
    for path in sorted(LIB.rglob("*.dart")):
        rel = str(path.relative_to(ROOT))
        if rel in SKIP or rel.endswith(GENERATED):
            continue
        text = path.read_text()
        lines = text.count("\n") + 1
        if lines > MAX_LINES:
            problems.append(f"{rel}: {lines} lines (max {MAX_LINES})")
        for m in widget_fn.finditer(text):
            name = m.group(1)
            if name != "build" and not name.startswith("_build"):
                line = text.count("\n", 0, m.start()) + 1
                problems.append(f"{rel}:{line}: widget function '{name}' should be _build…")
        problems += check_imports(rel, text)
        problems += check_names(rel)
    for p in problems:
        print(p)
    print(f"structure: {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
