"""Build the bundled, part-of-speech tagged Tatoeba example index.

Tatoeba sentences carry no part-of-speech information, so every English
sentence is tagged once with spaCy here. The app then shows only sentences in
which the word is used with the part of speech of the card (abandon `verb`
never gets "the abandon of ..."). Every sentence is tagged with the small
model; the best candidates are tagged again with the transformer model and
kept only when both agree ("How fast that dog runs!" is not a noun example).

Data: Tatoeba per-language exports (https://tatoeba.org/downloads),
CC BY 2.0 FR. Keep the attribution shown in the app.

Usage (spaCy needs Python <= 3.13):
    pip install spacy
    python -m spacy download en_core_web_sm
    pip install "spacy[transformers]"
    python -m spacy download en_core_web_trf
    python -X utf8 tool/build_examples.py --data <download dir>

<download dir> holds the per_language exports (downloaded when missing):
    eng/eng_sentences.tsv.bz2, eng/eng-<lang>_links.tsv.bz2,
    <lang>/<lang>_sentences.tsv.bz2

Output:
    assets/examples/en.json   (bundled in the app)
        {"source", "license",
         "sentences": {id: text},
         "index":     {"word|pos": [id, ...]}}   # pos: noun verb adjective adverb
    <data repo>/examples/<code>.json   (downloaded by the app; publish with
                                        tool/publish_packs.py)
        {"lang", "source", "license",
         "human":   {id: translation},   # Tatoeba translations
         "machine": {id: translation}}   # from <data repo>/machine/<code>.json, only
                                         # for sentences without a human one
"""
import argparse
import bz2
import collections
import json
import pathlib
import pickle
import re
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "examples"
BASE = "https://downloads.tatoeba.org/exports/per_language/"

# App translation language code -> Tatoeba code.
LANGS = {
    "ko": "kor", "ja": "jpn", "zh": "cmn", "es": "spa", "fr": "fra",
    "de": "deu", "pt": "por", "vi": "vie", "th": "tha", "id": "ind",
}
SPACY_POS = {"NOUN": "noun", "VERB": "verb", "ADJ": "adjective", "ADV": "adverb"}

PER_KEY = 3  # best sentences overall
PER_LANG = 2  # ... plus enough to have this many translated per language
MAX_PER_KEY = 8
VERIFY_PER_KEY = 24  # candidates per word|pos tagged again with the trf model
MIN_WORDS, MAX_WORDS, MAX_CHARS = 4, 16, 110
WORD = re.compile(r"^[a-z][a-z'-]*$")
BAD = re.compile(r"[\"“”()\[\]{}<>/\\_#*@:;]|\d")
# Never shown to learners / ranked lower.
BLOCK = re.compile(
    r"\b(rap(e|ed|es|ing|ist)|sex\w*|porn\w*|nude|naked|suicide|cocaine|heroin"
    r"|nigg\w*|fuck\w*|shit\w*|bitch\w*|whore|slut|penis|vagina|breasts?)\b",
    re.IGNORECASE,
)
GRIM = re.compile(
    r"\b(kill\w*|murder\w*|dead|death|die[ds]?|dying|corpse|body|gun|shot"
    r"|stab\w*|blood\w*|Sami|Layla|Fadil|Dan|Linda)\b",
    re.IGNORECASE,
)


def fetch(data: pathlib.Path, rel: str) -> pathlib.Path:
    path = data / rel.split("/")[-1]
    if not path.exists():
        print("download", rel)
        urllib.request.urlretrieve(BASE + rel, path)
    return path


def read_tsv(path: pathlib.Path):
    with bz2.open(path, "rt", encoding="utf-8") as f:
        for line in f:
            yield line.rstrip("\n").split("\t")


def vocabulary() -> set[str]:
    words = set()
    for path in (ROOT / "assets" / "dictionaries").glob("*.json"):
        entries = json.loads(path.read_text(encoding="utf-8"))["entries"]
        words.update(w for w in entries if WORD.match(w))
    return words


def usable(text: str) -> bool:
    if len(text) > MAX_CHARS or BAD.search(text):
        return False
    if not text[0].isupper() or text[-1] not in ".!?":
        return False
    return MIN_WORDS <= len(text.split()) <= MAX_WORDS


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", required=True, type=pathlib.Path)
    parser.add_argument("--processes", type=int, default=4)
    # Local clone of github.com/overlayered01/vocabulary-data, next to the app.
    parser.add_argument(
        "--packs", type=pathlib.Path, default=ROOT.parent / "vocabulary-data"
    )
    args = parser.parse_args()
    data: pathlib.Path = args.data
    data.mkdir(parents=True, exist_ok=True)

    english = {
        int(i): text
        for i, _, text in read_tsv(fetch(data, "eng/eng_sentences.tsv.bz2"))
        if usable(text) and not BLOCK.search(text)
    }
    print("english sentences", len(english))

    # Per language: English id -> shortest translation.
    translations: dict[str, dict[int, str]] = {}
    for code, tat in LANGS.items():
        links = collections.defaultdict(list)
        for eng, other in read_tsv(fetch(data, f"eng/eng-{tat}_links.tsv.bz2")):
            if int(eng) in english:
                links[int(other)].append(int(eng))
        found: dict[int, str] = {}
        for i, _, text in read_tsv(fetch(data, f"{tat}/{tat}_sentences.tsv.bz2")):
            for eng in links.get(int(i), ()):
                if eng not in found or len(text) < len(found[eng]):
                    found[eng] = text
        translations[code] = found
        print(code, "translated", len(found))

    tagged_path = data / "tagged.pickle"
    if tagged_path.exists():
        tagged = pickle.loads(tagged_path.read_bytes())
    else:
        import spacy

        nlp = spacy.load("en_core_web_sm", disable=["parser", "ner"])
        ids = list(english)
        tagged = {}
        docs = nlp.pipe(
            (english[i] for i in ids), batch_size=2000, n_process=args.processes
        )
        for n, (i, doc) in enumerate(zip(ids, docs)):
            tagged[i] = [
                (t.lemma_.lower(), SPACY_POS[t.pos_], t.text.lower())
                for t in doc
                if t.pos_ in SPACY_POS
            ]
            if n % 100000 == 0:
                print("tagged", n, flush=True)
        tagged_path.write_bytes(pickle.dumps(tagged))

    words = vocabulary()
    candidates = collections.defaultdict(list)
    for i, tokens in tagged.items():
        if i not in english:  # filtered after tagging
            continue
        lemmas = collections.Counter(lemma for lemma, _, _ in tokens)
        for lemma, pos, surface in tokens:
            # The app highlights and blanks `\bword\w*`, so the sentence must
            # use a form that starts with the headword (abandon -> abandoned).
            # "lighter" is its own headword, not an example of light `adj`.
            if (
                lemma in words
                and surface.startswith(lemma)
                and (surface == lemma or surface not in words)
                and lemmas[lemma] == 1
            ):
                candidates[(lemma, pos)].append(i)

    def score(i: int) -> float:
        text = english[i]
        n = len(text.split())
        langs = sum(1 for code in LANGS if i in translations[code])
        # Prefer 6-11 words, many translations, fewer stock names.
        s = langs * 2 - abs(n - 8) * 0.6
        if re.search(r"\b(Tom|Mary)\b", text):
            s -= 3
        if GRIM.search(text):
            s -= 6
        return s

    def shortlist(ids: list[int]) -> list[int]:
        ranked = sorted(set(ids), key=lambda i: (-score(i), i))
        picked = ranked[:VERIFY_PER_KEY]
        # Keep a few translated ones per language even if they rank lower.
        for code in LANGS:
            picked += [i for i in ranked if i in translations[code]][:4]
        return sorted(set(picked), key=lambda i: (-score(i), i))

    # Second opinion from the transformer model on the shortlist only.
    ranked_by_key = {key: shortlist(ids) for key, ids in candidates.items()}
    checked_path = data / "checked_trf.pickle"
    checked = (
        pickle.loads(checked_path.read_bytes()) if checked_path.exists() else {}
    )
    todo = sorted(
        {i for ids in ranked_by_key.values() for i in ids} - checked.keys()
    )
    if todo:
        import spacy

        nlp = spacy.load("en_core_web_trf", disable=["parser", "ner"])
        docs = nlp.pipe((english[i] for i in todo), batch_size=256)
        for n, (i, doc) in enumerate(zip(todo, docs)):
            checked[i] = {
                (t.lemma_.lower(), SPACY_POS[t.pos_])
                for t in doc
                if t.pos_ in SPACY_POS
            }
            if n % 50000 == 0:
                print("checked", n, "/", len(todo), flush=True)
        checked_path.write_bytes(pickle.dumps(checked))

    index: dict[str, list[int]] = {}
    for (lemma, pos), ids in ranked_by_key.items():
        ranked = [i for i in ids if (lemma, pos) in checked[i]]
        if not ranked:
            continue
        chosen: list[int] = []
        seen: set[str] = set()

        def take(i: int) -> None:
            key = re.sub(r"\W+", " ", english[i].lower())
            if i not in chosen and key not in seen and len(chosen) < MAX_PER_KEY:
                chosen.append(i)
                seen.add(key)

        for i in ranked:
            if len(chosen) >= PER_KEY:
                break
            take(i)
        for code in LANGS:
            have = sum(1 for i in chosen if i in translations[code])
            for i in ranked:
                if have >= PER_LANG or len(chosen) >= MAX_PER_KEY:
                    break
                if i in translations[code] and i not in chosen:
                    before = len(chosen)
                    take(i)
                    have += len(chosen) - before
        index[f"{lemma}|{pos}"] = chosen

    used = sorted({i for ids in index.values() for i in ids})
    OUT.mkdir(parents=True, exist_ok=True)
    meta = {"source": "https://tatoeba.org", "license": "CC BY 2.0 FR"}
    write(OUT / "en.json", {
        **meta,
        "sentences": {str(i): english[i] for i in used},
        "index": dict(sorted(index.items())),
    })
    packs = args.packs / "examples"
    packs.mkdir(parents=True, exist_ok=True)
    for code in LANGS:
        human = {
            str(i): translations[code][i] for i in used if i in translations[code]
        }
        machine_path = args.packs / "machine" / f"{code}.json"
        machine = (
            json.loads(machine_path.read_text(encoding="utf-8"))
            if machine_path.exists()
            else {}
        )
        write(packs / f"{code}.json", {
            "lang": code,
            **meta,
            "human": human,
            "machine": {
                str(i): machine[str(i)]
                for i in used
                if str(i) not in human and machine.get(str(i))
            },
        })
    print("keys", len(index), "sentences", len(used))


def write(path: pathlib.Path, value) -> None:
    path.write_text(
        json.dumps(value, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    print(path.name, f"{path.stat().st_size / 1e6:.2f}MB")


if __name__ == "__main__":
    main()
