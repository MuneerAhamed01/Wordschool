const EXAMPLE_ANSWER_WORDS = [
  "STUDY", "KNIFE", "HEIRS", "MUSIC", "PLANT", "CHAIR", "TABLE",
  "PHONE", "WATER", "LIGHT", "HOUSE", "WORLD", "DREAM", "HEART",
  "BREAD", "CLOUD", "GRASS", "SMILE", "TRAIN", "OCEAN",
];

export function buildSystemPrompt(): string {
  return [
    "You are a noir detective mystery writer for a mobile Wordle game.",
    "Generate one daily detective case as JSON only.",
    "Do not include markdown fences or commentary.",
    "",
    "Schema:",
    "{",
    "  \"title\": string,",
    "  \"introduction\": string,",
    "  \"resolution\": string,",
    "  \"clues\": [",
    "    {",
    "      \"index\": 0,",
    "      \"type\": \"location\",",
    "      \"hint\": string,",
    "      \"answer\": \"AAAAA\",",
    "      \"reaction\": string,",
    "      \"investigatePrompt\": string",
    "    },",
    "    { index: 1, type: \"weapon\", ... },",
    "    { index: 2, type: \"suspect\", ... }",
    "  ]",
    "}",
    "",
    "Rules:",
    "- Exactly 3 clues in order: location (index 0), weapon (1), suspect (2).",
    "- Each answer must be exactly 5 uppercase A-Z letters.",
    "- All three answers must be distinct valid Wordle solution words.",
    "- Hints must not spell out the answer directly.",
    "- Keep each narrative field under 500 words.",
    `- Example valid answer words: ${EXAMPLE_ANSWER_WORDS.join(", ")}.`,
  ].join("\n");
}

export function buildUserPrompt(dateId: string): string {
  return [
    `Generate today's detective case for date ${dateId}.`,
    "Return JSON only matching the schema.",
    "Make the mystery coherent across introduction, clues, reactions, and resolution.",
  ].join("\n");
}

export function buildRetryPrompt(
  dateId: string,
  previousError: string,
): string {
  return [
    buildUserPrompt(dateId),
    "",
    "The previous attempt failed validation:",
    previousError,
    "",
    "Fix all issues and return corrected JSON only.",
  ].join("\n");
}

export function buildAgentPrompt(dateId: string, userPrompt: string): string {
  return [
    buildSystemPrompt(),
    "",
    userPrompt,
  ].join("\n");
}
