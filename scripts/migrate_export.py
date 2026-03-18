#!/usr/bin/env python3
"""
Normalize legacy Pickup exports into the current import format.

Usage:
  python scripts/migrate_export.py --input old_export.json --output migrated.json
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import uuid
from pathlib import Path
from typing import Any, Dict, List, Tuple


def now_iso() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def ensure_iso(timestamp: Any) -> str:
    if isinstance(timestamp, str) and timestamp.strip():
        return timestamp
    return now_iso()


def normalize_comment(raw: Any) -> Dict[str, Any] | None:
    if not isinstance(raw, dict):
        return None
    text = str(raw.get("text", "")).strip()
    if not text:
        return None
    return {
        "text": text,
        "timestamp": ensure_iso(raw.get("timestamp")),
    }


def normalize_entry(raw: Any) -> Dict[str, Any] | None:
    if not isinstance(raw, dict):
        return None
    content = str(raw.get("content", "")).strip()
    image_path = raw.get("imagePath")
    song_info = raw.get("songInfo")
    if not content and not image_path:
        return None

    comments = raw.get("comments", [])
    normalized_comments = []
    if isinstance(comments, list):
        for c in comments:
            norm = normalize_comment(c)
            if norm:
                normalized_comments.append(norm)

    return {
        "id": str(raw.get("id") or uuid.uuid4()),
        "content": content,
        "imagePath": image_path if isinstance(image_path, str) and image_path.strip() else None,
        "songInfo": song_info if isinstance(song_info, str) and song_info.strip() else None,
        "timestamp": ensure_iso(raw.get("timestamp")),
        "comments": normalized_comments,
    }


def normalize_ai_entry(raw: Any) -> Dict[str, Any] | None:
    if not isinstance(raw, dict):
        return None
    question = str(raw.get("question", "")).strip()
    answer = str(raw.get("answer", "")).strip()
    if not question or not answer:
        return None

    type_value = str(raw.get("type", "recall")).strip().lower()
    if type_value not in {"recall", "summary"}:
        type_value = "recall"

    comments = raw.get("comments", [])
    normalized_comments = []
    if isinstance(comments, list):
        for c in comments:
            norm = normalize_comment(c)
            if norm:
                normalized_comments.append(norm)

    return {
        "id": str(raw.get("id") or uuid.uuid4()),
        "question": question,
        "answer": answer,
        "type": type_value,
        "timestamp": ensure_iso(raw.get("timestamp")),
        "comments": normalized_comments,
    }


def normalize_payload(payload: Any) -> Tuple[Dict[str, Any], Dict[str, int]]:
    raw_entries: List[Any] = []
    raw_ai_entries: List[Any] = []

    if isinstance(payload, list):
        raw_entries = payload
    elif isinstance(payload, dict):
        maybe_entries = payload.get("entries")
        maybe_ai = payload.get("aiEntries")
        if isinstance(maybe_entries, list):
            raw_entries = maybe_entries
        if isinstance(maybe_ai, list):
            raw_ai_entries = maybe_ai
    else:
        raise ValueError("Unsupported JSON root type.")

    entries: List[Dict[str, Any]] = []
    ai_entries: List[Dict[str, Any]] = []
    skipped_entries = 0
    skipped_ai = 0

    for item in raw_entries:
        normalized = normalize_entry(item)
        if normalized:
            entries.append(normalized)
        else:
            skipped_entries += 1

    for item in raw_ai_entries:
        normalized = normalize_ai_entry(item)
        if normalized:
            ai_entries.append(normalized)
        else:
            skipped_ai += 1

    normalized_payload = {
        "schema": "pickup-export-v2",
        "exportedAt": now_iso(),
        "entries": entries,
        "aiEntries": ai_entries,
    }
    stats = {
        "entries_kept": len(entries),
        "entries_skipped": skipped_entries,
        "ai_kept": len(ai_entries),
        "ai_skipped": skipped_ai,
    }
    return normalized_payload, stats


def main() -> None:
    parser = argparse.ArgumentParser(description="Normalize Pickup export data.")
    parser.add_argument("--input", required=True, help="Source JSON file path.")
    parser.add_argument("--output", required=True, help="Output JSON file path.")
    args = parser.parse_args()

    src = Path(args.input)
    dst = Path(args.output)

    payload = json.loads(src.read_text(encoding="utf-8"))
    normalized, stats = normalize_payload(payload)
    dst.write_text(json.dumps(normalized, ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"Migrated file written: {dst}")
    print(
        "Entries kept/skipped: {entries_kept}/{entries_skipped}; "
        "AI kept/skipped: {ai_kept}/{ai_skipped}".format(**stats)
    )


if __name__ == "__main__":
    main()
