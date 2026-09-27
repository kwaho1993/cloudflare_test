# Local development with a remote D1 snapshot

Run `run-with-remote-d1.bat` to:

1. Export the configured remote D1 database to `.wrangler/remote-d1.sql`.
2. Import it into a fresh, isolated local D1 persistence directory.
3. Build the Astro site and start the local Worker with the built static assets.

Open <http://127.0.0.1:8787>. Press `Ctrl+C` in the console to stop the server.

Each run creates a new `.wrangler/remote-copy-*` directory so it preserves existing local snapshots. Data changes made by the local server stay in that snapshot and are not written back to remote D1. The `.wrangler/` directory is git-ignored. Cloudflare's export command may briefly make the remote database unavailable while it creates the export.
