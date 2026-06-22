export type ClueType = "location" | "weapon" | "suspect";

export interface DetectiveClue {
  index: number;
  type: ClueType;
  hint: string;
  answer: string;
  reaction: string;
  investigatePrompt: string;
}

export interface DetectiveCasePayload {
  id?: string;
  title: string;
  introduction: string;
  clues: DetectiveClue[];
  resolution: string;
  createdAt?: string;
}

export const CLUE_TYPES_IN_ORDER: ClueType[] = ["location", "weapon", "suspect"];

export const MAX_NARRATIVE_LENGTH = 2000;
