// Hot-reload dev server for local UI work. Serves index.html with Bun's
// built-in HMR (instant CSS/JS updates, auto-reload on HTML changes) and
// proxies /media/* to the local SeaweedFS S3 store, mirroring nginx's role
// in docker-compose.yml.
//
// Start the S3 store first: docker compose up -d s3 s3-init
// Then run: bun run dev

import index from "./index.html";
import photography from "./photography.html";

const S3_ORIGIN = "http://localhost:8333/folio";

Bun.serve({
  port: 3000,
  development: true,
  routes: {
    "/": index,
    "/photography.html": photography,
  },
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname.startsWith("/media/")) {
      const target = S3_ORIGIN + url.pathname.slice("/media".length);
      try {
        return await fetch(target);
      } catch {
        return new Response(
          "Could not reach S3 store. Start it with: docker compose up -d s3 s3-init",
          { status: 502 },
        );
      }
    }
    return new Response("Not Found", { status: 404 });
  },
});

console.log("Dev server running at http://localhost:3000");
