import { zValidator } from "@hono/zod-validator";
import { desc } from "drizzle-orm";
import type { AnyD1Database } from "drizzle-orm/d1";
import { Hono } from "hono";
import { z } from "zod";
import { createDb } from "../db";
import { notes } from "../db/schema";

type Bindings = {
  DB: AnyD1Database;
};

const app = new Hono<{ Bindings: Bindings }>().basePath("/api");
const createNoteSchema = z.object({
  content: z.string().trim().min(1).max(240),
});

app.get("/health", async (c) => {
  await c.env.DB.prepare("SELECT 1").first();
  return c.json({ ok: true, service: "cloudflare-test-api", database: "connected" });
});

app.get("/notes", async (c) => {
  const db = createDb(c.env.DB);
  const result = await db.select().from(notes).orderBy(desc(notes.createdAt)).all();
  return c.json(result);
});

app.post("/notes", zValidator("json", createNoteSchema), async (c) => {
  const { content } = c.req.valid("json");
  const db = createDb(c.env.DB);
  const [note] = await db
    .insert(notes)
    .values({ content, createdAt: Date.now() })
    .returning();

  return c.json(note, 201);
});

app.onError((error, c) => {
  console.error(error);
  return c.json({ error: "Internal server error" }, 500);
});

app.notFound((c) => c.json({ error: "Not found" }, 404));

export default app;
