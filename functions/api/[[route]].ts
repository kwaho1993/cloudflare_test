import { handle } from "hono/cloudflare-pages";
import app from "../../src/api/app";

export const onRequest = handle(app);
