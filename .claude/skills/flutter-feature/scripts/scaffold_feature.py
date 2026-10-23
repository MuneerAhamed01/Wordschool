#!/usr/bin/env python3
"""Scaffold a clean-architecture slice for the Kerala PSC Flutter app (psc-dev).

Generates, following the repo's existing conventions (see CLAUDE.md):

  lib/features/<feature>/domain/entities/<entity>.dart
  lib/features/<feature>/domain/repositories/<feature>_repository.dart      (if missing)
  lib/features/<feature>/domain/usecases/<usecase>.dart
  lib/features/<feature>/domain/usecases/utils/<usecase>_param.dart
  lib/features/<feature>/data/models/<entity>.dart
  lib/features/<feature>/data/data_source/<source>_service.dart             (if missing)
  lib/features/<feature>/data/data_source/remote/<source>_service.dart      (if missing)
  lib/features/<feature>/data/repositories/<feature>_repository_impl.dart   (if missing)
  lib/features/<feature>/presentation/bloc/<bloc>_bloc/<bloc>_bloc.dart     (optional)
  lib/features/<feature>/presentation/pages/<page>_page.dart                (optional)
  test/features/<feature>/data/models/<entity>_test.dart

It never overwrites an existing file (unless --force) and prints the DI and
router snippets to paste. Existing repository/data-source files are left
untouched; the script prints the method to add instead.

Example:
  python3 .claude/skills/flutter-feature/scripts/scaffold_feature.py \
    --feature crossword --entity crossword_daily --source crossword_content \
    --collection crosswordDaily \
    --fields "id:String,puzzleId:String,categoryId:String,wordCount:int,xpReward:int,publishedAt:DateTime?" \
    --usecase load_crossword_daily --bloc crossword_home --page crossword_home
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass

PACKAGE = "wordshool"


# ---------- naming helpers ----------

def pascal(snake: str) -> str:
    return "".join(p[:1].upper() + p[1:] for p in snake.split("_") if p)


def camel(snake: str) -> str:
    p = pascal(snake)
    return p[:1].lower() + p[1:]


def check_snake(value: str, flag: str) -> str:
    if not re.fullmatch(r"[a-z][a-z0-9_]*", value):
        sys.exit(f"{flag} must be snake_case (got {value!r})")
    return value


# ---------- fields ----------

@dataclass
class Field:
    name: str
    type: str
    nullable: bool

    @property
    def dart_type(self) -> str:
        return self.type + ("?" if self.nullable else "")

    def from_json(self, json_var: str = "json") -> str:
        raw = f"{json_var}['{self.name}']"
        t = self.type
        if self.name == "id" and t == "String":
            return f"documentId ?? {raw} as String" + ("?" if self.nullable else "")
        if t == "String":
            expr = f"{raw} as String"
        elif t == "int":
            expr = f"({raw} as num).toInt()"
        elif t == "double":
            expr = f"({raw} as num).toDouble()"
        elif t == "bool":
            expr = f"{raw} as bool"
        elif t == "DateTime":
            expr = f"FirebaseDTConverter.fromTimestamp({raw} as Timestamp)"
        elif t.startswith("List<") and t.endswith(">"):
            inner = t[5:-1]
            expr = f"{t}.from({raw} as List)"
            if inner not in ("String", "int", "double", "bool", "dynamic"):
                expr += f"  // TODO: map items to {inner}"
        elif t.startswith("Map<"):
            expr = f"{t}.from({raw} as Map)"
        else:
            expr = f"{raw} as {t}  // TODO: parse {t}"
        if self.nullable:
            if t == "String":
                return f"{raw} as String?"
            if t == "bool":
                return f"{raw} as bool?"
            return f"{raw} == null ? null : {expr}"
        return expr

    def to_json(self) -> str:
        if self.type == "DateTime":
            if self.nullable:
                return (f"{self.name} == null ? null : "
                        f"FirebaseDTConverter.toTimestamp({self.name}!)")
            return f"FirebaseDTConverter.toTimestamp({self.name})"
        return self.name


def parse_fields(spec: str) -> list[Field]:
    fields: list[Field] = []
    depth = 0
    token = ""
    parts: list[str] = []
    for ch in spec:  # split on commas that are not inside <...>
        if ch == "<":
            depth += 1
        elif ch == ">":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append(token)
            token = ""
        else:
            token += ch
    if token.strip():
        parts.append(token)
    for part in parts:
        part = part.strip()
        if ":" not in part:
            sys.exit(f"Field {part!r} must be name:Type")
        name, typ = (s.strip() for s in part.split(":", 1))
        nullable = typ.endswith("?")
        typ = typ.rstrip("?")
        if not re.fullmatch(r"[a-z][A-Za-z0-9]*", name):
            sys.exit(f"Field name {name!r} must be camelCase")
        fields.append(Field(name, typ, nullable))
    if not fields:
        sys.exit("--fields needs at least one field")
    return fields


# ---------- templates ----------

def entity_file(entity: str, fields: list[Field]) -> str:
    cls = pascal(entity) + "Entity"
    props = ", ".join(f.name for f in fields)
    decl = "\n".join(f"  final {f.dart_type} {f.name};" for f in fields)
    ctor = "\n".join(
        f"    {'' if f.nullable else 'required '}this.{f.name}," for f in fields)
    return f"""import 'package:equatable/equatable.dart';

class {cls} extends Equatable {{
  const {cls}({{
{ctor}
  }});

{decl}

  @override
  List<Object?> get props => [{props}];
}}
"""


def model_file(feature: str, entity: str, fields: list[Field]) -> str:
    ent = pascal(entity) + "Entity"
    cls = pascal(entity) + "Model"
    needs_ts = any(f.type == "DateTime" for f in fields)
    imports = []
    if needs_ts:
        imports.append("import 'package:cloud_firestore/cloud_firestore.dart';")
        imports.append(f"import 'package:{PACKAGE}/core/firebase/dt_converter.dart';")
    imports.append(
        f"import 'package:{PACKAGE}/features/{feature}/domain/entities/{entity}.dart';")
    ctor = "\n".join(f"    {'' if f.nullable else 'required '}super.{f.name}," for f in fields)
    from_json = "\n".join(f"      {f.name}: {f.from_json()}," for f in fields)
    to_json = "\n".join(f"      '{f.name}': {f.to_json()}," for f in fields if f.name != "id")
    return f"""{chr(10).join(imports)}

class {cls} extends {ent} {{
  const {cls}({{
{ctor}
  }});

  factory {cls}.fromJson(Map<String, dynamic> json, {{String? documentId}}) {{
    return {cls}(
{from_json}
    );
  }}

  Map<String, dynamic> toJson() {{
    return {{
{to_json}
    }};
  }}
}}
"""


def repository_file(feature: str, entity: str, method: str) -> str:
    repo = pascal(feature) + "Repository"
    ent = pascal(entity) + "Entity"
    return f"""import 'package:{PACKAGE}/core/resorces/data_state.dart';
import 'package:{PACKAGE}/features/{feature}/domain/entities/{entity}.dart';

abstract class {repo} {{
  Future<DataState<{ent}>> {method}(String id);
}}
"""


def source_interface_file(feature: str, entity: str, source: str, method: str) -> str:
    ds = pascal(source) + "DataSource"
    model = pascal(entity) + "Model"
    return f"""import 'package:{PACKAGE}/core/resorces/data_state.dart';
import 'package:{PACKAGE}/features/{feature}/data/models/{entity}.dart';

abstract class {ds} {{
  Future<DataState<{model}>> {method}(String id);
}}
"""


def source_impl_file(feature: str, entity: str, source: str, method: str,
                     collection: str) -> str:
    ds = pascal(source) + "DataSource"
    model = pascal(entity) + "Model"
    human = entity.replace("_", " ")
    return f"""import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:{PACKAGE}/core/firebase/collections.dart';
import 'package:{PACKAGE}/core/resorces/data_state.dart';
import 'package:{PACKAGE}/features/{feature}/data/data_source/{source}_service.dart';
import 'package:{PACKAGE}/features/{feature}/data/models/{entity}.dart';

class {ds}Impl extends {ds} {{
  {ds}Impl({{required FirebaseFirestore firestore}}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<DataState<{model}>> {method}(String id) async {{
    try {{
      final snapshot = await _firestore
          .collection(FirebaseCollections.{collection})
          .doc(id)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {{
        return DataError<{model}>(
          error: AppError(
            error: '{collection}/$id not found',
            code: '404',
            message: "This {human} isn't available.",
          ),
        );
      }}

      return DataSuccess<{model}>(
        data: {model}.fromJson(data, documentId: snapshot.id),
      );
    }} catch (error, stackTrace) {{
      log('{ds}.{method} failed', error: error, stackTrace: stackTrace);
      return DataError<{model}>(
        error: AppError(error: error, code: '500'),
      );
    }}
  }}
}}
"""


def repository_impl_file(feature: str, entity: str, source: str, method: str) -> str:
    repo = pascal(feature) + "Repository"
    ds = pascal(source) + "DataSource"
    ent = pascal(entity) + "Entity"
    field = "_" + camel(source) + "DataSource"
    param = camel(source) + "DataSource"
    return f"""import 'package:{PACKAGE}/core/resorces/data_state.dart';
import 'package:{PACKAGE}/features/{feature}/data/data_source/{source}_service.dart';
import 'package:{PACKAGE}/features/{feature}/domain/entities/{entity}.dart';
import 'package:{PACKAGE}/features/{feature}/domain/repositories/{feature}_repository.dart';

class {repo}Impl implements {repo} {{
  {repo}Impl({{required {ds} {param}}}) : {field} = {param};

  final {ds} {field};

  @override
  Future<DataState<{ent}>> {method}(String id) {{
    return {field}.{method}(id);
  }}
}}
"""


def param_file(usecase: str) -> str:
    cls = pascal(usecase) + "Param"
    return f"""class {cls} {{
  const {cls}({{required this.id}});

  final String id;
}}
"""


def usecase_file(feature: str, entity: str, usecase: str, method: str) -> str:
    cls = pascal(usecase) + "UseCase"
    param = pascal(usecase) + "Param"
    repo = pascal(feature) + "Repository"
    ent = pascal(entity) + "Entity"
    field = "_" + camel(feature) + "Repository"
    arg = camel(feature) + "Repository"
    return f"""import 'package:{PACKAGE}/core/resorces/data_state.dart';
import 'package:{PACKAGE}/core/resorces/usecase.dart';
import 'package:{PACKAGE}/features/{feature}/domain/entities/{entity}.dart';
import 'package:{PACKAGE}/features/{feature}/domain/repositories/{feature}_repository.dart';
import 'package:{PACKAGE}/features/{feature}/domain/usecases/utils/{usecase}_param.dart';

class {cls} extends UseCase<DataState<{ent}>, {param}> {{
  {cls}({{required {repo} {arg}}}) : {field} = {arg};

  final {repo} {field};

  @override
  Future<DataState<{ent}>> call({{required {param} param}}) {{
    return {field}.{method}(param.id);
  }}
}}
"""


def bloc_file(feature: str, entity: str, bloc: str, usecase: str) -> str:
    b = pascal(bloc)
    uc = pascal(usecase) + "UseCase"
    param = pascal(usecase) + "Param"
    ent = pascal(entity) + "Entity"
    field = "_" + camel(usecase) + "UseCase"
    arg = camel(usecase) + "UseCase"
    return f"""import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{PACKAGE}/core/resorces/data_state.dart';
import 'package:{PACKAGE}/features/{feature}/domain/entities/{entity}.dart';
import 'package:{PACKAGE}/features/{feature}/domain/usecases/{usecase}.dart';
import 'package:{PACKAGE}/features/{feature}/domain/usecases/utils/{usecase}_param.dart';

// ---------- Events ----------

sealed class {b}Event {{
  const {b}Event();
}}

final class {b}Started extends {b}Event {{
  const {b}Started(this.id);

  final String id;
}}

final class {b}Retried extends {b}Event {{
  const {b}Retried();
}}

// ---------- States ----------

sealed class {b}State {{
  const {b}State();
}}

final class {b}Initial extends {b}State {{
  const {b}Initial();
}}

final class {b}Loading extends {b}State {{
  const {b}Loading();
}}

final class {b}Loaded extends {b}State {{
  const {b}Loaded(this.data);

  final {ent} data;
}}

final class {b}Failure extends {b}State {{
  const {b}Failure(this.message);

  final String message;
}}

// ---------- Bloc ----------

class {b}Bloc extends Bloc<{b}Event, {b}State> {{
  {b}Bloc({{required {uc} {arg}}})
      : {field} = {arg},
        super(const {b}Initial()) {{
    on<{b}Started>(_onStarted);
    on<{b}Retried>(_onRetried);
  }}

  final {uc} {field};
  String? _lastId;

  Future<void> _onStarted({b}Started event, Emitter<{b}State> emit) async {{
    _lastId = event.id;
    emit(const {b}Loading());

    final result = await {field}(param: {param}(id: event.id));

    if (result is DataSuccess<{ent}> && result.data != null) {{
      emit({b}Loaded(result.data!));
      return;
    }}
    emit({b}Failure(result.error?.message ?? 'Something went wrong'));
  }}

  void _onRetried({b}Retried event, Emitter<{b}State> emit) {{
    final id = _lastId;
    if (id != null) add({b}Started(id));
  }}
}}
"""


def page_file(feature: str, bloc: str, page: str) -> str:
    p = pascal(page) + "Page"
    b = pascal(bloc)
    route = "/" + page.replace("_", "-")
    return f"""import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{PACKAGE}/features/{feature}/presentation/bloc/{bloc}_bloc/{bloc}_bloc.dart';

class {p} extends StatelessWidget {{
  const {p}({{super.key}});

  static const String routeName = '{route}';

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<{b}Bloc, {b}State>(
          builder: (context, state) {{
            return switch (state) {{
              {b}Initial() || {b}Loading() =>
                const Center(child: CircularProgressIndicator()),
              {b}Failure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            context.read<{b}Bloc>().add(const {b}Retried()),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              {b}Loaded(:final data) => Center(
                  // TODO: build the screen from design/screens/*.md
                  child: Text('$data'),
                ),
            }};
          }},
        ),
      ),
    );
  }}
}}
"""


def model_test_file(feature: str, entity: str, fields: list[Field]) -> str:
    cls = pascal(entity) + "Model"
    sample = {
        "String": "'sample'", "int": "3", "double": "1.5", "bool": "true",
        "DateTime": "Timestamp.fromDate(DateTime.utc(2026, 10, 22))",
    }
    needs_ts = any(f.type == "DateTime" for f in fields)
    lines = []
    for f in fields:
        if f.name == "id":
            continue
        if f.type in sample:
            val = sample[f.type]
        elif f.type.startswith("List<"):
            val = "<dynamic>[]"
        elif f.type.startswith("Map<"):
            val = "<String, dynamic>{}"
        else:
            val = "null /* TODO */"
        lines.append(f"      '{f.name}': {val},")
    has_id = any(f.name == "id" for f in fields)
    id_check = ("      expect(model.id, 'doc-1');\n" if has_id else "")
    imports = ["import 'package:flutter_test/flutter_test.dart';"]
    if needs_ts:
        imports.insert(0, "import 'package:cloud_firestore/cloud_firestore.dart';")
    imports.append(f"import 'package:{PACKAGE}/features/{feature}/data/models/{entity}.dart';")
    return f"""{chr(10).join(imports)}

void main() {{
  group('{cls}', () {{
    final json = <String, dynamic>{{
{chr(10).join(lines)}
    }};

    test('fromJson reads every field', () {{
      final model = {cls}.fromJson(json, documentId: 'doc-1');
{id_check}      // TODO: assert each field
    }});

    test('toJson round-trips', () {{
      final model = {cls}.fromJson(json, documentId: 'doc-1');
      expect({cls}.fromJson(model.toJson(), documentId: 'doc-1'), model);
    }});
  }});
}}
"""


# ---------- main ----------

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=".", help="repo root (default: cwd)")
    ap.add_argument("--feature", required=True, help="snake_case feature folder, e.g. crossword")
    ap.add_argument("--entity", required=True, help="snake_case entity, e.g. crossword_puzzle")
    ap.add_argument("--fields", required=True,
                    help='"id:String,title:String,count:int,createdAt:DateTime?"')
    ap.add_argument("--source", help="snake_case data source name (default: <feature>)")
    ap.add_argument("--collection", required=True,
                    help="FirebaseCollections constant name, e.g. crosswordPuzzles")
    ap.add_argument("--usecase", help="snake_case use case, e.g. load_crossword_puzzle")
    ap.add_argument("--method", help="repository method name (default: get<Entity>)")
    ap.add_argument("--bloc", help="snake_case bloc name (optional)")
    ap.add_argument("--page", help="snake_case page name (optional, needs --bloc)")
    ap.add_argument("--force", action="store_true", help="overwrite existing files")
    ap.add_argument("--dry-run", action="store_true", help="print paths only")
    a = ap.parse_args()

    feature = check_snake(a.feature, "--feature")
    entity = check_snake(a.entity, "--entity")
    source = check_snake(a.source or feature, "--source")
    usecase = check_snake(a.usecase or f"load_{entity}", "--usecase")
    method = a.method or ("get" + pascal(entity))
    if a.page and not a.bloc:
        sys.exit("--page needs --bloc")
    fields = parse_fields(a.fields)

    lib = os.path.join(a.root, "lib", "features", feature)
    test = os.path.join(a.root, "test", "features", feature)
    if not os.path.isdir(os.path.join(a.root, "lib")):
        sys.exit(f"No lib/ under {os.path.abspath(a.root)} — run from the repo root or pass --root")

    plan: list[tuple[str, str, bool]] = [  # (path, content, shared)
        (f"{lib}/domain/entities/{entity}.dart", entity_file(entity, fields), False),
        (f"{lib}/data/models/{entity}.dart", model_file(feature, entity, fields), False),
        (f"{lib}/domain/repositories/{feature}_repository.dart",
         repository_file(feature, entity, method), True),
        (f"{lib}/data/data_source/{source}_service.dart",
         source_interface_file(feature, entity, source, method), True),
        (f"{lib}/data/data_source/remote/{source}_service.dart",
         source_impl_file(feature, entity, source, method, a.collection), True),
        (f"{lib}/data/repositories/{feature}_repository_impl.dart",
         repository_impl_file(feature, entity, source, method), True),
        (f"{lib}/domain/usecases/utils/{usecase}_param.dart", param_file(usecase), False),
        (f"{lib}/domain/usecases/{usecase}.dart",
         usecase_file(feature, entity, usecase, method), False),
        (f"{test}/data/models/{entity}_test.dart", model_test_file(feature, entity, fields), False),
    ]
    if a.bloc:
        bloc = check_snake(a.bloc, "--bloc")
        plan.append((f"{lib}/presentation/bloc/{bloc}_bloc/{bloc}_bloc.dart",
                     bloc_file(feature, entity, bloc, usecase), False))
    if a.page:
        page = check_snake(a.page, "--page")
        plan.append((f"{lib}/presentation/pages/{page}_page.dart",
                     page_file(feature, a.bloc, page), False))

    created, skipped, extend = [], [], []
    for path, content, shared in plan:
        rel = os.path.relpath(path, a.root)
        if os.path.exists(path) and not a.force:
            (extend if shared else skipped).append(rel)
            continue
        if not a.dry_run:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(content)
        created.append(rel)

    print(("Would create" if a.dry_run else "Created") + f" {len(created)} file(s):")
    for p in created:
        print("  +", p)
    for p in skipped:
        print("  = exists, skipped:", p)
    if extend:
        ent = pascal(entity)
        print("\nShared files already exist — add this method by hand:")
        for p in extend:
            print("  ~", p)
        print(f"    Future<DataState<{ent}Entity|Model>> {method}(String id);")

    ds = pascal(source) + "DataSource"
    repo = pascal(feature) + "Repository"
    uc = pascal(usecase) + "UseCase"
    print(f"""
--- lib/di.dart (inside _initialize{pascal(feature)}(), create it if missing) ---
  getIt.registerSingleton<{ds}>(
    {ds}Impl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerSingleton<{repo}>(
    {repo}Impl({camel(source)}DataSource: getIt<{ds}>()),
  );
  getIt.registerSingleton<{uc}>(
    {uc}({camel(feature)}Repository: getIt<{repo}>()),
  );""")
    if a.page:
        print(f"""
--- lib/core/routes/app_router.dart ---
      GoRoute(
        path: {pascal(a.page)}Page.routeName,
        builder: (context, state) => BlocProvider(
          create: (_) => {pascal(a.bloc)}Bloc({camel(usecase)}UseCase: getIt())
            ..add(const {pascal(a.bloc)}Started('TODO-id')),
          child: const {pascal(a.page)}Page(),
        ),
      ),""")
    print(f"""
--- lib/core/firebase/collections.dart (if missing) ---
  static const String {a.collection} = '{a.collection}';

Next: fill TODOs, then `fvm flutter analyze && fvm flutter test`.""")


if __name__ == "__main__":
    main()
