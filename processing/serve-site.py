#!/usr/bin/env python3
"""Serve the site directory over HTTP, including the `latest` alias.

`site/latest` is a symbolic link in Git but a plain text file on checkouts
without symbolic-link support, so the alias is resolved per request instead of
relying on the file system.

The first output line names the address, for example
`Serving /path/site at http://127.0.0.1:8080/`. Use --port 0 to pick a free port.
"""
import argparse
import http.server
import os
import posixpath
import signal
import socketserver
import sys
import urllib.parse


def resolve_latest(site):
    entry = os.path.join(site, "latest")
    if os.path.islink(entry):
        return os.path.basename(os.readlink(entry).rstrip("/\\"))
    if os.path.isfile(entry):
        with open(entry, encoding="utf-8") as handle:
            return handle.read().strip()
    return None


class SiteHandler(http.server.SimpleHTTPRequestHandler):
    site = "."

    def translate_path(self, path):
        bare = urllib.parse.unquote(path.split("?", 1)[0].split("#", 1)[0])
        if bare == "/latest" or bare.startswith("/latest/"):
            version = resolve_latest(self.site)
            if version:
                bare = "/" + version + bare[len("/latest"):]
        parts = [p for p in posixpath.normpath(bare).split("/") if p and p not in (".", "..")]
        return os.path.join(self.site, *parts)


class SiteServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--site", default="site", help="directory to serve")
    parser.add_argument("--port", type=int, default=8080, help="port, 0 picks a free one")
    args = parser.parse_args()

    site = os.path.abspath(args.site)
    handler = type("Handler", (SiteHandler,), {"site": site})
    server = SiteServer(("127.0.0.1", args.port), handler)
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))

    print("Serving %s at http://127.0.0.1:%d/" % (site, server.server_address[1]), flush=True)
    try:
        server.serve_forever()
    except (KeyboardInterrupt, SystemExit):
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
