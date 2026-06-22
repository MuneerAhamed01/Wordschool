import * as fs from "fs";
import * as path from "path";

let answerWords: Set<string> | null = null;

function resolveAnswersPath(): string {
  const candidates = [
    path.resolve(__dirname, "../../../assets/words/answers.txt"),
    path.resolve(__dirname, "../../../../assets/words/answers.txt"),
    path.resolve(process.cwd(), "../assets/words/answers.txt"),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  throw new Error(
    "Could not locate assets/words/answers.txt. Expected at repo root.",
  );
}

export function loadAnswerWords(): Set<string> {
  if (answerWords) {
    return answerWords;
  }

  const filePath = resolveAnswersPath();
  const content = fs.readFileSync(filePath, "utf8");
  answerWords = new Set(
    content
      .split("\n")
      .map((line) => line.trim().toLowerCase())
      .filter((word) => word.length === 5),
  );

  return answerWords;
}

export function resetAnswerWordsCacheForTests(): void {
  answerWords = null;
}
