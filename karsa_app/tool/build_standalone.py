#!/usr/bin/env python3
"""Bangun satu berkas HTML mandiri dari preview KARSA.

Preview di `karsa_app/preview/` butuh server (styles.css, app.js,
curriculum-data.js, dan aset gambar dimuat terpisah). Sandbox preview memakai
token akses, jadi URL mentahnya tidak bisa dibuka langsung di tab baru.
Berkas hasil skrip ini menanam SEMUA aset (CSS, JS, gambar, font) sebagai data
URI, sehingga bisa dibuka langsung dari disk tanpa server dan tanpa token.

Pemakaian:
    python3 karsa_app/tool/build_standalone.py
    # -> karsa_app/preview/karsa-standalone.html
"""

from __future__ import annotations

import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREVIEW = ROOT / "preview"
ASSETS = ROOT / "assets"

# Berkas gambar yang dirujuk app.js, dipetakan ke nama di folder assets.
IMAGES = {
    "./assets/images/icon.png": "images/icon.png",
    "./assets/images/karsa-login-logo.png": "images/karsa-login-logo.png",
    "./assets/images/logo-sd-karitas.png": "images/logo-sd-karitas.png",
    "./assets/images/splash-art.png": "images/splash-art.png",
    "./assets/images/student-banner.png": "images/student-banner.png",
    "./assets/images/teacher-banner.png": "images/teacher-banner.png",
}


def data_uri(path: Path, mime: str) -> str:
    return "data:%s;base64,%s" % (mime, base64.b64encode(path.read_bytes()).decode("ascii"))


def build() -> Path:
    html = (PREVIEW / "index.html").read_text(encoding="utf-8")
    css = (PREVIEW / "styles.css").read_text(encoding="utf-8")
    app_js = (PREVIEW / "app.js").read_text(encoding="utf-8")
    curriculum = (PREVIEW / "curriculum-data.js").read_text(encoding="utf-8")

    # Font ikon ditanam di CSS.
    css = css.replace(
        "url('./assets/fonts/Ionicons.ttf')",
        "url('%s')" % data_uri(ASSETS / "fonts" / "Ionicons.ttf", "font/ttf"),
        1,
    )

    # Semua gambar ditanam di app.js.
    for rel, name in IMAGES.items():
        app_js = app_js.replace(rel, data_uri(ASSETS / name, "image/png"))

    # Favicon ditanam.
    html = html.replace(
        'href="./assets/images/icon.png"',
        'href="%s"' % data_uri(ASSETS / "images" / "icon.png", "image/png"),
        1,
    )

    # Gabungkan menjadi satu dokumen.
    html = html.replace(
        '<link rel="stylesheet" href="./styles.css" />',
        "<style>\n%s\n</style>" % css,
        1,
    )
    html = html.replace(
        '<script src="./curriculum-data.js"></script>\n  <script src="./app.js"></script>',
        "<script>\n%s\n</script>\n  <script>\n%s\n</script>" % (curriculum, app_js),
        1,
    )

    # Jangan tinggalkan rujukan berkas luar: berkasnya harus benar-benar mandiri.
    if "<script src=" in html or 'href="./styles.css"' in html or "./assets/" in html:
        raise SystemExit("Gagal: masih ada rujukan berkas luar di hasil build")

    out = PREVIEW / "karsa-standalone.html"
    out.write_text(html, encoding="utf-8")
    print("OK: %s (%.2f MB)" % (out.relative_to(ROOT.parent), out.stat().st_size / 1048576))
    return out


if __name__ == "__main__":
    build()
