#!/usr/bin/env python3
"""Static syntax, import, asset, and cross-file symbol checker for karsa_app (no Dart SDK required)."""

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
