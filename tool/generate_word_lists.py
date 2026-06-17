#!/usr/bin/env python3
"""Generate common 5-letter word lists for WordSchool from word frequency data."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "words"

# zipf_frequency scale (wordfreq): ~3.5+ = familiar everyday words for daily puzzles
# ~2.3+ = recognizable words allowed as guesses (excludes obscure/archaic terms)
ANSWER_ZIPF_MIN = 3.5
GUESS_ZIPF_MIN = 2.3


def is_clean_word(word: str) -> bool:
    """Drop slang/repetitive tokens that slip through frequency scoring."""
    if len(set(word)) < 3:
        return False
    for i in range(len(word) - 2):
        if word[i] == word[i + 1] == word[i + 2]:
            return False
    return True


def main() -> None:
    try:
        from wordfreq import top_n_list, zipf_frequency
    except ImportError:
        print(
            "wordfreq is required. Run:\n"
            "  python3 -m venv .venv_words\n"
            "  .venv_words/bin/pip install wordfreq\n"
            "  .venv_words/bin/python tool/generate_word_lists.py",
            file=sys.stderr,
        )
        sys.exit(1)

    answers: set[str] = set()
    guesses: set[str] = set()

    for word in top_n_list("en", 150_000):
        if not re.fullmatch(r"[a-z]{5}", word):
            continue
        if not is_clean_word(word):
            continue
        zipf = zipf_frequency(word, "en")
        if zipf >= ANSWER_ZIPF_MIN:
            answers.add(word)
            guesses.add(word)
        elif zipf >= GUESS_ZIPF_MIN:
            guesses.add(word)

    answer_list = sorted(answers)
    guess_list = sorted(guesses)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    answers_path = OUT_DIR / "answers.txt"
    words_path = OUT_DIR / "words.txt"

    answers_path.write_text("\n".join(answer_list) + "\n", encoding="utf-8")
    words_path.write_text("\n".join(guess_list) + "\n", encoding="utf-8")

    print(f"Wrote {len(answer_list)} answer words -> {answers_path}")
    print(f"Wrote {len(guess_list)} guess words  -> {words_path}")


if __name__ == "__main__":
    main()
