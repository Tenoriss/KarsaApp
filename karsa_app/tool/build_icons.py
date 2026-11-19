#!/usr/bin/env python3
"""Bangun `karsa_app/preview/icon-paths.js` dari paket npm `ionicons`.

Preview dulu merender ikon sebagai glyph font (Private Use Area,
U+F100-U+F8FF) dari `assets/fonts/Ionicons.ttf`. Glyph PUA itu TIDAK punya
fallback ke font sistem: begitu berkas font gagal dimuat, ikonnya hilang tanpa
jejak dan tombol ikon tampak sebagai lingkaran kosong. Itu penyebab keluhan
"tombol mode terang hilang".

Skrip ini mengubah isi `svg/<nama>.svg` resmi Ionicons menjadi potongan SVG
inline yang disimpan di `preview/icon-paths.js`. Dengan begitu ikon selalu
tampil tanpa bergantung pada pemuatan berkas font, dan warnanya mengikuti
`currentColor` (otomatis benar di mode terang maupun gelap).

Pemakaian:
    # butuh paket ionicons yang sudah diekstrak (mis. `npm pack ionicons@7.4.0`)
    python3 karsa_app/tool/build_icons.py --svg-dir /tmp/ion/package/dist/svg

    # atau biarkan skrip mengunduh dari registry npm:
    python3 karsa_app/tool/build_icons.py
"""

from __future__ import annotations

import argparse
import io
import json
import re
import tarfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREVIEW = ROOT / "preview"
CURRICULUM = PREVIEW / "curriculum-data.js"
OUT = PREVIEW / "icon-paths.js"

IONICONS_VERSION = "7.4.0"
REGISTRY = "https://registry.npmjs.org/ionicons/-/ionicons-%s.tgz" % IONICONS_VERSION


def icon_names() -> list[str]:
    """Ambil daftar ikon dari peta `icons` di curriculum-data.js."""
    src = CURRICULUM.read_text(encoding="utf-8")
    match = re.search(r'"icons"\s*:\s*\{(.*?)\n  \}', src, re.S)
    if not match:
        raise SystemExit("Gagal: peta \"icons\" tidak ditemukan di curriculum-data.js")
    return re.findall(r'"([a-z0-9-]+)"\s*:', match.group(1))


def download_svgs() -> dict[str, str]:
    """Unduh paket ionicons dari registry npm, kembalikan {nama: isi svg}."""
    print("mengunduh %s ..." % REGISTRY)
    with urllib.request.urlopen(REGISTRY, timeout=120) as resp:
        blob = resp.read()
    out: dict[str, str] = {}
    with tarfile.open(fileobj=io.BytesIO(blob), mode="r:gz") as tar:
        for member in tar.getmembers():
            name = member.name
            if not name.startswith("package/dist/svg/") or not name.endswith(".svg"):
                continue
            handle = tar.extractfile(member)
            if handle is None:
                continue
            out[Path(name).stem] = handle.read().decode("utf-8")
    return out


def read_svgs(svg_dir: Path) -> dict[str, str]:
    return {p.stem: p.read_text(encoding="utf-8") for p in svg_dir.glob("*.svg")}


def inner_markup(raw: str) -> str:
    """Ambil isi <svg> saja; pembungkus svg dibuat oleh app.js."""
    match = re.search(r"<svg[^>]*>(.*)</svg>", raw, re.S)
    if not match:
        raise SystemExit("Gagal: berkas SVG tanpa elemen <svg>")
    return re.sub(r"\s+", " ", match.group(1)).strip()


HEADER = """/* Ikon Ionicons sebagai SVG inline.
 *
 * Sebelumnya ikon dirender sebagai glyph font (Private Use Area,
 * U+F100\u2013U+F8FF) dari Ionicons.ttf. Glyph PUA tidak punya fallback font
 * sistem: kalau berkas font gagal dimuat \u2014 mis. dibuka langsung dari disk,
 * atau dari dalam iframe tanpa jaringan \u2014 ikonnya HILANG tanpa jejak dan
 * tombol ikon tampak sebagai lingkaran kosong. Contoh nyata: tombol mode
 * terang di header sapaan terlihat "hilang".
 *
 * Dengan SVG inline, ikon selalu tampil: warnanya ikut `currentColor`,
 * jadi otomatis benar di mode terang maupun gelap.
 *
 * Sumber: paket npm ionicons@%s (MIT), svg/<nama>.svg, 512\u00d7512.
 * Dibuat oleh karsa_app/tool/build_icons.py \u2014 jangan disunting tangan.
 */"""


def build(svg_dir: Path | None) -> Path:
    names = icon_names()
    svgs = read_svgs(svg_dir) if svg_dir else download_svgs()

    missing = [n for n in names if n not in svgs]
    if missing:
        raise SystemExit("Gagal: SVG tidak ditemukan untuk: %s" % ", ".join(missing))

    lines = [HEADER % IONICONS_VERSION, "(function () {", "  'use strict';", ""]
    lines.append("  window.KARSA_ICONS = {")
    for index, name in enumerate(names):
        markup = inner_markup(svgs[name])
        escaped = markup.replace("\\", "\\\\").replace('"', '\\"')
        comma = "," if index < len(names) - 1 else ""
        lines.append('    "%s": "%s"%s' % (name, escaped, comma))
    lines.append("  };")
    lines.append("}());")
    lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print("OK: %s (%d ikon, %d byte)" % (OUT.relative_to(ROOT.parent), len(names), OUT.stat().st_size))
    return OUT


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--svg-dir",
        type=Path,
        default=None,
        help="folder svg/ hasil ekstrak paket ionicons (tanpa ini: unduh dari npm)",
    )
    parser.add_argument(
        "--emit-names",
        action="store_true",
        help="cetak daftar nama ikon lalu keluar",
    )
    args = parser.parse_args()
    if args.emit_names:
        print(json.dumps(icon_names()))
        return 0
    build(args.svg_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
