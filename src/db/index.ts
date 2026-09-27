import { drizzle } from "drizzle-orm/d1";
import type { AnyD1Database } from "drizzle-orm/d1";
import * as schema from "./schema";

export function createDb(binding: AnyD1Database) {
  return drizzle(binding, { schema });
}
