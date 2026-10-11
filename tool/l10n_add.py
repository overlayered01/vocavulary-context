"""Add or update localization messages in every lib/l10n/app_*.arb file.

Usage: python -X utf8 tool/l10n_add.py messages.json

messages.json: {"key": {"ko": "...", "en": "...", ..., "@": {placeholders meta}}}
Languages missing from an entry are left untouched.
"""
import json
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"
messages = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
for arb in sorted(root.glob("app_*.arb")):
    lang = arb.stem.split("_", 1)[1]
    data = json.loads(arb.read_text(encoding="utf-8"))
    for key, entry in messages.items():
        if lang in entry:
            data[key] = entry[lang]
        if lang == "ko" and "@" in entry:
            data["@" + key] = entry["@"]
    arb.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(arb.name, len(data))
