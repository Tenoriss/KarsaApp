#!/usr/bin/env python3
"""Static syntax, import, asset, and compile-risk checker for karsa_app.

No Dart SDK is required. Besides balanced delimiters, imports, assets, and
member references, this catches a handful of type-level mistakes that a
syntax-only pass cannot see:

* non-`late` final fields missing from every constructor,
* positional arguments to the named-only `Image`/`ImageIcon` constructors,
* `.isEmpty` on a nullable local produced by `x == null ? null : ...`,
* locally defined classes used as `ClassName.member` without a direct import.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

SDK_OR_EXTERNAL_PACKAGES = {
    "flutter",
    "flutter_test",
    "provider",
    "shared_preferences",
    "file_picker",
    "path_provider",
    "share_plus",
    "open_filex",
    "pdf",
    "excel",
}


def strip_comments_and_strings(src: str, filepath: Path, errors: list[str]) -> str:
    """Validate string/comment termination and return source with strings/comments blanked out."""
    n = len(src)
    i = 0
    out: list[str] = []
    line = 1

    while i < n:
        ch = src[i]
        if ch == "\n":
            line += 1
            out.append("\n")
            i += 1
            continue

        # Line comment
        if ch == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                out.append(" ")
                i += 1
            continue

        # Block comment
        if ch == "/" and i + 1 < n and src[i + 1] == "*":
            start_line = line
            out.extend([" ", " "])
            i += 2
            closed = False
            while i < n:
                if src[i] == "\n":
                    line += 1
                    out.append("\n")
                    i += 1
                elif src[i] == "*" and i + 1 < n and src[i + 1] == "/":
                    out.extend([" ", " "])
                    i += 2
                    closed = True
                    break
                else:
                    out.append(" ")
                    i += 1
            if not closed:
                errors.append(f"{filepath}:{start_line}: Unclosed block comment /*")
            continue

        # Raw string r'''...''', r"""...""", r'...', r"..."
        if ch == "r" and i + 1 < n and src[i + 1] in ("'", '"'):
            quote = src[i + 1]
            start_line = line
            if i + 3 < n and src[i + 1 : i + 4] == quote * 3:
                delim = quote * 3
                out.extend([" "] * 4)
                i += 4
                closed = False
                while i < n:
                    if src[i : i + 3] == delim:
                        out.extend([" "] * 3)
                        i += 3
                        closed = True
                        break
                    if src[i] == "\n":
                        line += 1
                        out.append("\n")
                    else:
                        out.append(" ")
                    i += 1
                if not closed:
                    errors.append(f"{filepath}:{start_line}: Unclosed raw multiline string")
                continue
            else:
                out.extend([" ", " "])
                i += 2
                closed = False
                while i < n:
                    if src[i] == quote:
                        out.append(" ")
                        i += 1
                        closed = True
                        break
                    if src[i] == "\n":
                        errors.append(f"{filepath}:{start_line}: Unclosed raw string literal")
                        closed = True
                        break
                    out.append(" ")
                    i += 1
                if not closed:
                    errors.append(f"{filepath}:{start_line}: Unclosed raw string literal at EOF")
                continue

        # Normal or multiline string
        if ch in ("'", '"'):
            quote = ch
            start_line = line
            if i + 2 < n and src[i : i + 3] == quote * 3:
                delim = quote * 3
                out.extend([" "] * 3)
                i += 3
                closed = False
                while i < n:
                    if src[i] == "\\" and i + 1 < n:
                        out.extend([" ", "\n" if src[i + 1] == "\n" else " "])
                        if src[i + 1] == "\n":
                            line += 1
                        i += 2
                        continue
                    if src[i : i + 3] == delim:
                        out.extend([" "] * 3)
                        i += 3
                        closed = True
                        break
                    if src[i] == "\n":
                        line += 1
                        out.append("\n")
                    else:
                        out.append(" ")
                    i += 1
                if not closed:
                    errors.append(f"{filepath}:{start_line}: Unclosed multiline string")
                continue
            else:
                out.append(" ")
                i += 1
                closed = False
                interp_depth = 0
                while i < n:
                    c = src[i]
                    if c == "\\" and i + 1 < n:
                        out.extend([" ", " "])
                        i += 2
                        continue
                    if c == "$" and i + 1 < n and src[i + 1] == "{":
                        # Scan balanced interpolation braces inside single-line string
                        interp_depth += 1
                        out.extend([" ", " "])
                        i += 2
                        while i < n and interp_depth > 0:
                            ic = src[i]
                            if ic == "\\" and i + 1 < n:
                                out.extend([" ", " "])
                                i += 2
                                continue
                            if ic in ("'", '"'):
                                iq = ic
                                out.append(" ")
                                i += 1
                                while i < n and src[i] != iq:
                                    if src[i] == "\\" and i + 1 < n:
                                        out.extend([" ", " "])
                                        i += 2
                                    else:
                                        if src[i] == "\n":
                                            line += 1
                                            out.append("\n")
                                        else:
                                            out.append(" ")
                                        i += 1
                                if i < n:
                                    out.append(" ")
                                    i += 1
                                continue
                            if ic == "{":
                                interp_depth += 1
                            elif ic == "}":
                                interp_depth -= 1
                            if ic == "\n":
                                line += 1
                                out.append("\n")
                            else:
                                out.append(" ")
                            i += 1
                        continue
                    if c == quote:
                        out.append(" ")
                        i += 1
                        closed = True
                        break
                    if c == "\n":
                        errors.append(f"{filepath}:{start_line}: Unclosed single-line string literal")
                        closed = True
                        break
                    out.append(" ")
                    i += 1
                if not closed:
                    errors.append(f"{filepath}:{start_line}: Unclosed string literal at EOF")
                continue

        out.append(ch)
        i += 1

    return "".join(out)


def check_balanced_delimiters(stripped: str, filepath: Path, errors: list[str]) -> None:
    pairs = {"(": ")", "[": "]", "{": "}"}
    closing = {v: k for k, v in pairs.items()}
    stack: list[tuple[str, int]] = []
    line = 1
    for ch in stripped:
        if ch == "\n":
            line += 1
        elif ch in pairs:
            stack.append((ch, line))
        elif ch in closing:
            if not stack:
                errors.append(f"{filepath}:{line}: Unexpected closing '{ch}'")
            else:
                top, open_line = stack.pop()
                if top != closing[ch]:
                    errors.append(
                        f"{filepath}:{line}: Mismatched '{ch}' for '{top}' opened at line {open_line}"
                    )
    for ch, open_line in stack:
        errors.append(f"{filepath}:{open_line}: Unclosed '{ch}'")


def collect_top_level_symbols(stripped: str) -> set[str]:
    symbols: set[str] = set()
    patterns = [
        r"\bclass\s+([A-Za-z_]\w*)",
        r"\benum\s+([A-Za-z_]\w*)",
        r"\bmixin\s+([A-Za-z_]\w*)",
        r"\btypedef\s+([A-Za-z_]\w*)",
        r"\bextension\s+([A-Za-z_]\w*)",
    ]
    for pat in patterns:
        for m in re.finditer(pat, stripped):
            symbols.add(m.group(1))
    return symbols


def check_imports_and_assets(
    dart_files: list[Path], symbols_by_file: dict[Path, set[str]], errors: list[str]
) -> None:
    import_re = re.compile(r"""^\s*(?:import|export|part)\s+['"]([^'"]+)['"]""", re.MULTILINE)
    asset_re = re.compile(r"""['"](assets/[^'"]+)['"]""")

    for fp in dart_files:
        raw = fp.read_text(encoding="utf-8")
        for m in import_re.finditer(raw):
            uri = m.group(1)
            if uri.startswith("dart:"):
                continue
            if uri.startswith("package:"):
                pkg_and_rest = uri[len("package:") :]
                pkg, _, rel = pkg_and_rest.partition("/")
                if pkg == "karsa_app":
                    target = (ROOT / "lib" / rel).resolve()
                    if not target.is_file():
                        errors.append(f"{fp}: Missing package import target '{uri}' -> {target}")
                elif pkg not in SDK_OR_EXTERNAL_PACKAGES:
                    errors.append(f"{fp}: Unknown package '{pkg}' in import '{uri}'")
            else:
                target = (fp.parent / uri).resolve()
                if not target.is_file():
                    errors.append(f"{fp}: Missing relative import '{uri}' -> {target}")

        for m in asset_re.finditer(raw):
            asset_rel = m.group(1)
            if "$" in asset_rel:
                continue
            target = ROOT / asset_rel
            if not target.is_file():
                errors.append(f"{fp}: Missing referenced asset '{asset_rel}'")


def check_member_references(dart_files: list[Path], errors: list[str]) -> None:
    def extract_members(rel_path: str) -> set[str]:
        txt = (ROOT / rel_path).read_text(encoding="utf-8")
        found: set[str] = {"_"}
        # Match getters: `<Type> get foo`
        for m in re.finditer(r"\bget\s+([A-Za-z_]\w*)\b", txt):
            found.add(m.group(1))
        # Match methods/fields at class member indent (2 spaces)
        for m in re.finditer(
            r"^\s{2}(?:static\s+)?(?:const\s+|final\s+)?[A-Za-z_][\w<>, ?]*?\s+([A-Za-z_]\w*)\s*(?:[=(;{]|=>)",
            txt,
            re.MULTILINE,
        ):
            found.add(m.group(1))
        found |= {"notifyListeners", "addListener", "removeListener", "dispose", "hasListeners"}
        return found

    app_state_members = extract_members("lib/providers/app_state.dart")
    icon_members = extract_members("lib/core/widgets/karsa_icons.dart")
    const_members = extract_members("lib/core/constants/app_constants.dart")
    color_members = extract_members("lib/core/theme/app_colors.dart")
    typo_members = extract_members("lib/core/theme/app_typography.dart")
    curriculum_members = extract_members("lib/data/curriculum_data.dart")
    date_members = extract_members("lib/core/utils/date_utils.dart")
    seed_members = extract_members("lib/data/seed_data.dart")

    checks = [
        (r"\bstate\.([A-Za-z_]\w*)", app_state_members, "AppState"),
        (r"\bKarsaIcons\.([A-Za-z_]\w*)", icon_members, "KarsaIcons"),
        (r"\bAppConstants\.([A-Za-z_]\w*)", const_members, "AppConstants"),
        (r"\bAppColors\.([A-Za-z_]\w*)", color_members, "AppColors"),
        (r"\btheme\.text\.([A-Za-z_]\w*)", typo_members, "AppTypography"),
        (r"\bCurriculumData\.([A-Za-z_]\w*)", curriculum_members, "CurriculumData"),
        (r"\bKarsaDateUtils\.([A-Za-z_]\w*)", date_members, "KarsaDateUtils"),
        (r"\bSeedData\.([A-Za-z_]\w*)", seed_members, "SeedData"),
    ]

    for fp in dart_files:
        raw = fp.read_text(encoding="utf-8")
        stripped = strip_comments_and_strings(raw, fp, [])
        for pattern, valid_set, owner in checks:
            for m in re.finditer(pattern, stripped):
                member = m.group(1)
                if member not in valid_set:
                    errors.append(f"{fp}: Unknown member '{owner}.{member}'")


def _class_bodies(stripped: str):
    """Yield (class name, class body) for each top-level class declaration."""
    for m in re.finditer(r"\bclass\s+(\w+)[^{]*\{", stripped):
        start = m.end() - 1
        depth = 0
        end = start
        for i in range(start, len(stripped)):
            if stripped[i] == "{":
                depth += 1
            elif stripped[i] == "}":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        yield m.group(1), stripped[start + 1 : end]


def check_field_initialization(dart_files: list[Path], errors: list[str]) -> None:
    """Every non-late final field must be initialized by a constructor.

    Dart's analyzer rejects a class whose final instance fields are declared
    but never initialized. This is easy to miss when a model gains new fields,
    so verify it statically (the SDK is not available in this workspace).
    """
    for fp in dart_files:
        stripped = strip_comments_and_strings(
            fp.read_text(encoding="utf-8"), fp, []
        )
        for class_name, body in _class_bodies(stripped):
            # Collect only constructor parameter lists and initializer lists.
            # `copyWith` bodies also mention `this.field`, but they do not
            # initialize the field and must not count.
            ctor_parts: list[str] = []
            for cm in re.finditer(
                r"^  (?:const\s+|factory\s+)?"
                + re.escape(class_name)
                + r"(?:\.\w+)?\s*\(",
                body,
                re.MULTILINE,
            ):
                open_idx = body.find("(", cm.start())
                depth = 0
                end = open_idx
                for i in range(open_idx, len(body)):
                    if body[i] == "(":
                        depth += 1
                    elif body[i] == ")":
                        depth -= 1
                        if depth == 0:
                            end = i
                            break
                params = body[open_idx + 1 : end]
                tail = body[end + 1 : end + 600]
                initializer = ""
                if tail.lstrip().startswith(":"):
                    stop = len(tail)
                    for token in ("{", ";"):
                        pos = tail.find(token)
                        if 0 <= pos < stop:
                            stop = pos
                    initializer = tail[:stop]
                ctor_parts.append(params + "\n" + initializer)
            ctor_text = "\n".join(ctor_parts)
            for line in body.split("\n"):
                if not re.match(r"^\s{2}(?:static\s+)?(?:late\s+)?final\s", line):
                    continue
                if "late " in line or "static " in line:
                    continue
                # `final x = <nilai>;` sudah terinisialisasi di tempatnya dan
                # tidak perlu (bahkan tidak boleh) diisi lewat konstruktor.
                decl_part = line.split("=", 1)[0]
                if "=" in line and decl_part.count("(") == decl_part.count(")"):
                    continue
                decl = line.split("=", 1)[0].strip().rstrip(";").strip()
                name = decl.split()[-1] if decl.split() else ""
                if not name or not re.match(r"^\w+$", name):
                    continue
                initialized = (
                    re.search(r"\bthis\." + re.escape(name) + r"\b", ctor_text)
                    or re.search(r"\b" + re.escape(name) + r"\s*=", ctor_text)
                )
                if not initialized:
                    errors.append(
                        f"{fp}: final field '{class_name}.{name}' is never initialized "
                        f"by a constructor (add it to the constructor parameter list)"
                    )


def check_image_constructor_args(dart_files: list[Path], errors: list[str]) -> None:
    """`Image` takes only named parameters; a positional argument won't compile."""
    named_only = {"Image", "ImageIcon", "Placeholder"}
    for fp in dart_files:
        stripped = strip_comments_and_strings(
            fp.read_text(encoding="utf-8"), fp, []
        )
        for cls in named_only:
            for m in re.finditer(r"\b" + cls + r"\s*\(", stripped):
                open_idx = stripped.find("(", m.start())
                depth = 0
                end = open_idx
                for i in range(open_idx, len(stripped)):
                    if stripped[i] == "(":
                        depth += 1
                    elif stripped[i] == ")":
                        depth -= 1
                        if depth == 0:
                            end = i
                            break
                args = stripped[open_idx + 1 : end].strip()
                if not args:
                    continue
                # Split on top-level commas only.
                parts: list[str] = []
                buf: list[str] = []
                inner = 0
                for ch in args:
                    if ch in "([{":
                        inner += 1
                    elif ch in ")]}":
                        inner -= 1
                    if ch == "," and inner == 0:
                        parts.append("".join(buf).strip())
                        buf = []
                    else:
                        buf.append(ch)
                if "".join(buf).strip():
                    parts.append("".join(buf).strip())
                for part in parts:
                    if part and not re.match(r"^[A-Za-z_]\w*\s*:", part):
                        errors.append(
                            f"{fp}: '{cls}' only accepts named arguments; "
                            f"positional argument '{part[:40]}' will not compile"
                        )
                        break


def check_nullable_conditional_deref(dart_files: list[Path], errors: list[str]) -> None:
    """A `x == null ? null : y` local must be null-checked before `.isEmpty`.

    Dart null safety rejects `x.isEmpty` when `x` is `List<T>?`. This pattern
    appears in the "open form" helpers, so catch it without needing an SDK.
    """
    for fp in dart_files:
        stripped = strip_comments_and_strings(
            fp.read_text(encoding="utf-8"), fp, []
        )
        lines = stripped.split("\n")
        for i, line in enumerate(lines):
            m = re.search(r"\bfinal\s+(\w+)\s*=\s*\w+\s*==\s*null", line)
            if not m:
                continue
            head = " ".join(lines[i : i + 3])
            if not re.search(r"\?\s*null\s*:", head):
                continue
            var = m.group(1)
            for following in lines[i + 1 : i + 14]:
                if re.search(r"\b" + re.escape(var) + r"\.isEmpty\b", following):
                    if (
                        re.search(r"\b" + re.escape(var) + r"\s*==\s*null", following)
                        or re.search(r"\b" + re.escape(var) + r"\s*!=\s*null", following)
                    ):
                        continue
                    errors.append(
                        f"{fp}: nullable local '{var}' is dereferenced with .isEmpty "
                        f"without a null check (add '{var} == null ||')"
                    )


def check_local_symbol_imports(
    dart_files: list[Path], symbols_by_file: dict[Path, set[str]], errors: list[str]
) -> None:
    """A locally defined class used as `Foo.bar` must be imported directly.

    Dart does not re-export transitively imported symbols, so referencing a
    class without importing its file is a compile error. External/SDK symbols
    are not defined in this workspace and are therefore ignored here.
    """
    owner_of: dict[str, set[Path]] = {}
    for fp, symbols in symbols_by_file.items():
        for symbol in symbols:
            owner_of.setdefault(symbol, set()).add(fp)

    for fp in dart_files:
        raw = fp.read_text(encoding="utf-8")
        stripped = strip_comments_and_strings(raw, fp, [])
        imported: set[Path] = set()
        for rel in re.findall(r"import\s+['\"]([^'\"]+)['\"]", raw):
            if rel.startswith("package:karsa_app/"):
                target = (ROOT / "lib" / rel[len("package:karsa_app/") :]).resolve()
            elif rel.startswith(("dart:", "package:")):
                continue
            else:
                target = (fp.parent / rel).resolve()
            if target.is_file():
                imported.add(target)
        own = symbols_by_file[fp]
        for name in sorted(set(re.findall(r"\b([A-Z]\w*)\s*\.", stripped))):
            if name in own or name not in owner_of:
                continue
            if not (owner_of[name] & imported):
                errors.append(
                    f"{fp}: '{name}' is defined in this project but not imported "
                    f"(add the import for its file)"
                )


def check_pubspec(errors: list[str]) -> None:
    pubspec = ROOT / "pubspec.yaml"
    if not pubspec.is_file():
        errors.append("Missing pubspec.yaml")
        return
    txt = pubspec.read_text(encoding="utf-8")
    for m in re.finditer(r"^\s*-\s*(?:asset:\s*)?(assets/\S+)", txt, re.MULTILINE):
        rel = m.group(1)
        if not (ROOT / rel).is_file():
            errors.append(f"pubspec.yaml: Declared asset '{rel}' does not exist")


def main() -> int:
    errors: list[str] = []
    dart_files = sorted(
        list((ROOT / "lib").rglob("*.dart"))
        + (list((ROOT / "test").rglob("*.dart")) if (ROOT / "test").is_dir() else [])
    )
    if not dart_files:
        print("ERROR: No .dart files found under lib/", file=sys.stderr)
        return 1

    symbols_by_file: dict[Path, set[str]] = {}
    total_lines = 0
    for fp in dart_files:
        raw = fp.read_text(encoding="utf-8")
        total_lines += raw.count("\n") + 1
        stripped = strip_comments_and_strings(raw, fp, errors)
        check_balanced_delimiters(stripped, fp, errors)
        symbols_by_file[fp] = collect_top_level_symbols(stripped)

    check_imports_and_assets(dart_files, symbols_by_file, errors)
    check_member_references(dart_files, errors)
    check_field_initialization(dart_files, errors)
    check_image_constructor_args(dart_files, errors)
    check_nullable_conditional_deref(dart_files, errors)
    check_local_symbol_imports(dart_files, symbols_by_file, errors)
    check_pubspec(errors)

    all_symbols = set().union(*symbols_by_file.values())
    if errors:
        print(f"FAILED: {len(errors)} issue(s) found across {len(dart_files)} Dart files:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(
        f"OK: Checked {len(dart_files)} Dart files ({total_lines} lines), "
        f"{len(all_symbols)} top-level classes/enums/mixins, all imports & assets resolved."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
