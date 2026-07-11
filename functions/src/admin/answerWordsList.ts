import * as fs from "fs";
import * as path from "path";

let answerWordsList: string[] | null = null;

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

  throw new Error("Could not locate assets/words/answers.txt");
}

export function loadAnswerWordsList(): string[] {
  if (answerWordsList) {
    return answerWordsList;
  }

  const content = fs.readFileSync(resolveAnswersPath(), "utf8");
  answerWordsList = content
    .split("\n")
    .map((line) => line.trim().toLowerCase())
    .filter((word) => word.length === 5);

  return answerWordsList;
}

export function resetAnswerWordsListCacheForTests(): void {
  answerWordsList = null;
}
