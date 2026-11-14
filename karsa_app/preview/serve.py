#!/usr/bin/env python3
"""Static preview server for the KarsaApp HTML preview.

Serves the files in this directory over HTTP with:

* no-cache headers (so every reload shows the latest edits),
* UTF-8 aware MIME types,
* a ``/healthz`` health endpoint,
* an ``/assets/...`` route that is mapped to the Flutter asset folder
  (``karsa_app/assets/...``) so the preview reuses the original PNGs and the
  Ionicons font without duplicating binary files in the repository.

Usage::

    python3 serve.py                     # http://127.0.0.1:8000
    python3 serve.py --host 0.0.0.0 --port 8080
"""

from __future__ import annotations

import argparse
import mimetypes
import os
import posixpath
import sys
from functools import partial
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote, urlparse

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FLUTTER_ASSETS_DIR = os.path.abspath(os.path.join(BASE_DIR, os.pardir, "assets"))

# Force UTF-8 for every text based MIME type (the default charset on the client
# side is latin-1 for some types, which would break the Indonesian copy).
mimetypes.add_type("text/html", ".html")
mimetypes.add_type("text/css", ".css")
mimetypes.add_type("text/javascript", ".js")
mimetypes.add_type("application/json", ".json")
mimetypes.add_type("image/png", ".png")
mimetypes.add_type("image/jpeg", ".jpg")
mimetypes.add_type("font/ttf", ".ttf")


class PreviewRequestHandler(SimpleHTTPRequestHandler):
    """Static file handler with no-cache headers and an ``/assets`` alias."""

    server_version = "KarsaPreview/1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    # -- helpers ------------------------------------------------------- #
    def _send_no_cache(self) -> None:
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")

    def _guess_type(self, path: str) -> str:
        ctype, _ = mimetypes.guess_type(path)
        if ctype is None:
            ctype = "application/octet-stream"
        if ctype.startswith("text/") or ctype in (
            "application/json",
            "application/javascript",
            "image/svg+xml",
        ):
            ctype += "; charset=utf-8"
        return ctype

    def translate_path(self, path: str) -> str:
        """Map ``/assets/...`` to the Flutter asset directory."""
        parsed = unquote(urlparse(path).path)
        parsed = posixpath.normpath(parsed)
        parts = [p for p in parsed.split("/") if p and p not in (os.curdir, os.pardir)]
        if parts and parts[0] == "assets":
            candidate = os.path.abspath(
                os.path.join(FLUTTER_ASSETS_DIR, *parts[1:])
            )
            root = FLUTTER_ASSETS_DIR + os.sep
            if candidate == FLUTTER_ASSETS_DIR or candidate.startswith(root):
                return candidate
        return super().translate_path(path)

    # -- verbs --------------------------------------------------------- #
    def do_GET(self) -> None:  # noqa: N802 - stdlib naming
        if urlparse(self.path).path.rstrip("/") == "/healthz":
            payload = b'{"status":"ok","service":"karsa-preview"}'
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self._send_no_cache()
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(payload)
            return
        super().do_GET()

    def do_HEAD(self) -> None:  # noqa: N802 - stdlib naming
        if urlparse(self.path).path.rstrip("/") == "/healthz":
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", "0")
            self._send_no_cache()
            self.end_headers()
            return
        super().do_HEAD()

    def send_head(self):
        """Serve files with UTF-8 MIME types and no-cache headers."""
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            index = os.path.join(path, "index.html")
            if os.path.isfile(index):
                path = index
            else:
                return super().send_head()
        try:
            f = open(path, "rb")
        except OSError:
            self.send_error(HTTPStatus.NOT_FOUND, "File not found")
            return None
        try:
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", self._guess_type(path))
            self.send_header("Content-Length", str(os.fstat(f.fileno()).st_size))
            self._send_no_cache()
            self.end_headers()
            return f
        except Exception:
            f.close()
            raise

    def end_headers(self) -> None:
        # Security header that keeps the preview embeddable in an iframe.
        self.send_header("X-Content-Type-Options", "nosniff")
        super().end_headers()

    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("[karsa-preview] %s - %s\n" % (self.address_string(), fmt % args))


def main() -> int:
    parser = argparse.ArgumentParser(description="Serve the KarsaApp HTML preview.")
    parser.add_argument("--host", default="127.0.0.1", help="bind address (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=8000, help="bind port (default: 8000)")
    args = parser.parse_args()

    if not os.path.isdir(FLUTTER_ASSETS_DIR):
        print(
            "warning: Flutter asset folder not found at %s" % FLUTTER_ASSETS_DIR,
            file=sys.stderr,
        )

    handler = partial(PreviewRequestHandler)
    with ThreadingHTTPServer((args.host, args.port), handler) as httpd:
        print("KarsaApp preview serving %s on http://%s:%d" % (BASE_DIR, args.host, args.port))
        print("Health check: http://%s:%d/healthz" % (args.host, args.port))
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nStopping preview server.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
