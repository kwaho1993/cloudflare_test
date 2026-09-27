import type { AnyD1Database } from "drizzle-orm/d1";
import app from "./api/app";

type Bindings = {
  DB: AnyD1Database;
  ASSETS: Fetcher;
};

export default {
  async fetch(request: Request, env: Bindings, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname.startsWith("/api/")) {
      return app.fetch(request, env, ctx);
    }
    return env.ASSETS.fetch(request);
  },
};
