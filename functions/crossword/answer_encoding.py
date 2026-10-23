"""Answer encoding shared with the app (CW-014, DEC-003).

`answerEnc = base64(utf8(answer) XOR utf8(puzzleId + ":" + wordId))`, key repeated over
the answer. **Obfuscation, not security** — the server re-scores with
`crosswordSolutions`. Dart twin: `lib/features/crossword/domain/utils/answer_encoding.dart`;
both are tested against `test/fixtures/answer_encoding.json`.
"""

import base64


def _xor(data: bytes, puzzle_id: str, word_id: str) -> bytes:
    key = f"{puzzle_id}:{word_id}".encode()
    return bytes(byte ^ key[index % len(key)] for index, byte in enumerate(data))


def encode_answer(answer: str, puzzle_id: str, word_id: str) -> str:
    """Encode one answer for the puzzle document.

    Args:
        answer: Plain answer, e.g. `VAIKOM`.
        puzzle_id: e.g. `kerala-history-0012`.
        word_id: e.g. `2D`.

    Returns:
        The base64 string stored as `answerEnc`.
    """
    return base64.b64encode(_xor(answer.encode(), puzzle_id, word_id)).decode("ascii")


def decode_answer(answer_enc: str, puzzle_id: str, word_id: str) -> str:
    """Reverse `encode_answer`."""
    return _xor(base64.b64decode(answer_enc), puzzle_id, word_id).decode()
