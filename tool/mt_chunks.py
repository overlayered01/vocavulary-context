"""Split example sentences that lack a human translation into chunks for
machine translation, and merge the translated chunks back.

    python -X utf8 tool/mt_chunks.py split ko --scope rep --size 500
    python -X utf8 tool/mt_chunks.py merge ko

split writes <data repo>/mt/<lang>/<n>.src.json   {id: English sentence}
A translator (API script, agent, Opus-MT, ...) writes   <n>.out.json {id: translation}
merge checks every chunk (missing ids, empty or untranslated text) and writes
<data repo>/machine/<lang>.json, which tool/build_examples.py puts under
"machine" in the downloadable pack.

--scope rep: one sentence per word|pos that has no translated example yet
--scope all: every indexed sentence without a human translation
"""
import argparse
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
# Local clone of github.com/overlayered01/vocabulary-data, next to the app.
PACKS = ROOT.parent / "vocabulary-data"


def load(path: pathlib.Path):
    return json.loads(path.read_text(encoding="utf-8"))


def split(lang: str, scope: str, size: int) -> None:
    en = load(ROOT / "assets" / "examples" / "en.json")
    human = load(PACKS / "examples" / f"{lang}.json")["human"]
    machine_path = PACKS / "machine" / f"{lang}.json"
    done = load(machine_path) if machine_path.exists() else {}
    if scope == "rep":
        ids = []
        for key, sentence_ids in en["index"].items():
            if not any(str(i) in human for i in sentence_ids):
                ids.append(str(sentence_ids[0]))
    else:
        ids = [i for i in en["sentences"] if i not in human]
    ids = [i for i in dict.fromkeys(ids) if i not in done]
    out = PACKS / "mt" / lang
    out.mkdir(parents=True, exist_ok=True)
    for n in range(0, len(ids), size):
        chunk = {i: en["sentences"][i] for i in ids[n:n + size]}
        path = out / f"{n // size + 1:04d}.src.json"
        path.write_text(json.dumps(chunk, ensure_ascii=False, indent=0),
                        encoding="utf-8")
    print(lang, scope, "sentences", len(ids), "chunks", -(-len(ids) // size),
          "chars", sum(len(en["sentences"][i]) for i in ids))


def merge(lang: str) -> None:
    out = PACKS / "mt" / lang
    machine_path = PACKS / "machine" / f"{lang}.json"
    merged = load(machine_path) if machine_path.exists() else {}
    latin = lang in {"es", "fr", "de", "pt", "vi", "id"}
    for src_path in sorted(out.glob("*.src.json")):
        out_path = src_path.with_name(src_path.name.replace(".src.", ".out."))
        if not out_path.exists():
            print("missing", out_path.name)
            continue
        src, got = load(src_path), load(out_path)
        bad = [
            i for i, text in src.items()
            if not isinstance(got.get(i), str) or not got[i].strip()
            or (not latin and re.fullmatch(r"[\x00-\x7f]*", got[i]))
            or got[i].strip() == text.strip()
        ]
        extra = set(got) - set(src)
        for i in src:
            if i not in bad:
                merged[i] = got[i].strip()
        print(src_path.name, "ok", len(src) - len(bad), "bad", len(bad),
              "extra", len(extra))
    machine_path.parent.mkdir(parents=True, exist_ok=True)
    machine_path.write_text(json.dumps(merged, ensure_ascii=False),
                            encoding="utf-8")
    print("machine", lang, len(merged))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["split", "merge"])
    parser.add_argument("lang")
    parser.add_argument("--scope", choices=["rep", "all"], default="rep")
    parser.add_argument("--size", type=int, default=500)
    args = parser.parse_args()
    if args.command == "split":
        split(args.lang, args.scope, args.size)
    else:
        merge(args.lang)


if __name__ == "__main__":
    main()
