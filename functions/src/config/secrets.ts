import {defineSecret} from "firebase-functions/params";

export const cursorApiKey = defineSecret("CURSOR_API_KEY");
export const seedSecret = defineSecret("SEED_SECRET");

export const DEFAULT_CURSOR_MODEL = "composer-2.5";

export function getCursorModel(): string {
  return process.env.CURSOR_MODEL?.trim() || DEFAULT_CURSOR_MODEL;
}

export const MAX_GENERATION_ATTEMPTS = 3;
