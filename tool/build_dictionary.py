"""Build the bundled English->X dictionary from a Wiktionary edition.

Data: Kaikki.org extraction of the X-language Wiktionary edition (English
headwords explained in X). License: CC BY-SA 4.0 (Wiktionary contributors);
keep the attribution shown in the app.

Usage:
    python -X utf8 tool/build_dictionary.py ko             # download + build
    python -X utf8 tool/build_dictionary.py ja --input a.jsonl [b.jsonl ...]

The Chinese edition is mostly Traditional; it is converted to Simplified with
OpenCC (`pip install opencc-python-reimplemented`).

Output: assets/dictionaries/<code>.json
    {"source", "license",
     "entries":   {word: [[pos, [gloss, ...]], ...]},
     "redirects": {inflected form: base form}}   # took -> take
pos uses the app's English keys (noun, verb, adjective, ...).
"""
import argparse
import json
import pathlib
import re
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent


def _hans(text: str) -> str:
    from opencc import OpenCC  # only needed for zh

    global _hans_converter
    try:
        converter = _hans_converter
    except NameError:
        converter = _hans_converter = OpenCC("t2s")
    return converter.convert(text)


# Wiktionary edition -> Kaikki page names of the English language (some
# editions split English across pages), a regex a gloss must match to count as
# written in that language, and an optional text conversion.
EDITIONS = {
    "ko": {"pages": ["영어"], "script": r"[가-힣]"},
    "ja": {"pages": ["英語"], "script": r"[぀-ヿ一-鿿]"},
    "zh": {
        "pages": ["英語", "英语"],
        "script": r"[一-鿿]",
        "convert": _hans,
    },
    # Later: fr Anglais, de Englisch, es Inglés, pt Inglês, vi Tiếng Anh,
    # th อังกฤษ (need their own script checks).
}

POS = {
    "noun": "noun", "verb": "verb", "adj": "adjective", "adv": "adverb",
    "pron": "pronoun", "prep": "preposition", "conj": "conjunction",
    "intj": "interjection", "article": "article", "det": "determiner",
    "num": "numeral", "phrase": "phrase", "prep_phrase": "phrase",
    "proverb": "phrase",
}
# Korean edition: many entries are "unknown"; recover from categories.
CATEGORY_POS = {
    "명사": "noun", "동사": "verb", "타동사": "verb", "자동사": "verb",
    "형용사": "adjective", "부사": "adverb", "대명사": "pronoun",
    "전치사": "preposition", "접속사": "conjunction", "감탄사": "interjection",
    "수사": "numeral", "관용구": "phrase", "숙어": "phrase",
}
# Proper nouns, abbreviations and affixes are not useful for word learning.
SKIP_POS = {"name", "abbrev", "prefix", "suffix", "symbol", "character"}
# Same idea as the app's filter for the online dictionary.
UNCOMMON = {"archaic", "obsolete", "dated", "rare", "historical", "slang",
            "vulgar", "offensive", "derogatory", "nonstandard", "misspelling"}

# Editorial markers that are not part of the meaning.
MARKERS = re.compile(
    r"^\s*(\((타동사|자동사|타|자|명사|동사)\)|\[(타동사|자동사)\])\s*"
)
HANGUL = r"[가-힣]"


def clean(gloss: str) -> str:
    g = gloss.strip()
    g = re.sub(r"^\d+(\.\d+)*\s*[.:)]?\s*:?\s*", "", g)  # "1. :" numbering
    g = re.sub(r"[㉠-㉿①-⑳]", "", g)  # ㉠..㉿, ①..⑳
    while MARKERS.match(g):
        g = MARKERS.sub("", g, count=1)
    g = re.sub(r"\s*cf\.\s*[A-Za-z][^。；;]*[。.]?", "", g)  # "cf.walk."
    # Drop parentheticals that only hold English explanations.
    g = re.sub(r"\s*\(\([^()]*\)\)\s*", " ", g)
    g = re.sub(r"\s*\((?=[^()]*[A-Za-z])[^()぀-鿿가-힣]{12,}\)\s*", " ", g)
    # Grammar notes and long leading explanations: "(自動詞)", "（源自…而）".
    g = re.sub(r"^\s*[(（](自動詞|他動詞|不及物|及物)[)）]\s*", "", g)
    g = re.sub(r"^\s*（[^（）]{9,}）\s*", "", g)  # zh/ja full-width only
    # "잡다.가져오다", "달리다. 뛰다" -> comma lists (keeps "...으로").
    g = re.sub(rf"(?<={HANGUL})\.\s*(?={HANGUL})", ", ", g)
    # Long explanations: keep the first clause.
    if len(g) > 24:
        g = re.split(r"[；;]", g)[0]
    g = re.sub(r"。(?=\S)", "、", g.strip())  # "得る。手に入れる"
    g = re.sub(r"\s+", " ", g).strip(" .;:,。；")
    return g


LATIN = re.compile(r"[A-Za-z]")


def example_pair(example: dict, word: str, script, convert):
    """(English sentence, translation) for a usage example, or None.

    The Korean edition often writes both in one string ("Clean it. 청소해."),
    so the translation starts at the first character of the edition's script.
    """
    text = (example.get("text") or "").strip()
    translation = (example.get("translation") or "").strip()
    if not translation:
        match = script.search(text)
        if match:
            text, translation = text[:match.start()].strip(), text[match.start():].strip()
    text = re.sub(r"\s+", " ", text).strip(" —-")
    translation = convert(re.sub(r"\s+", " ", translation).strip())
    if not (12 <= len(text) <= 140) or script.search(text):
        return None
    if "—" in text or len(text.split()) < 4 or text.count("(") != text.count(")"):
        return None
    if not LATIN.search(text) or "[" in text or "…" in text or "..." in text:
        return None
    if not re.search(rf"\b{re.escape(word)}", text, re.IGNORECASE):
        return None
    if translation and (len(translation) > 140 or not script.search(translation)
                        or translation.count("(") != translation.count(")")):
        translation = ""
    return [text, translation]


def part_of_speech(entry: dict) -> str:
    pos = POS.get(entry.get("pos", ""))
    if pos:
        return pos
    title = entry.get("pos_title") or ""
    if title in CATEGORY_POS:
        return CATEGORY_POS[title]
    for category in entry.get("categories", []):
        name = category.get("name", "")
        for suffix, value in CATEGORY_POS.items():
            if name.endswith(" " + suffix):
                return value
    return ""


def download(code: str) -> list[pathlib.Path]:
    paths = []
    for index, page in enumerate(EDITIONS[code]["pages"]):
        name = urllib.parse.quote(page)
        url = (f"https://kaikki.org/{code}wiktionary/{name}/"
               f"kaikki.org-dictionary-{name}.jsonl")
        target = ROOT / "build" / f"kaikki-{code}-en-{index}.jsonl"
        target.parent.mkdir(parents=True, exist_ok=True)
        print(f"downloading {url}")
        request = urllib.request.Request(
            url, headers={"User-Agent": "Mozilla/5.0"}
        )
        with urllib.request.urlopen(request, timeout=600) as response:
            target.write_bytes(response.read())
        paths.append(target)
    return paths


def build(code: str, sources: list[pathlib.Path]) -> dict:
    edition = EDITIONS[code]
    script = re.compile(edition["script"])
    convert = edition.get("convert", lambda text: text)
    entries: dict[str, dict[str, list[str]]] = {}
    examples: dict[str, dict[str, list[list[str]]]] = {}
    redirects: dict[str, str] = {}
    for source in sources:
        for line in source.open(encoding="utf-8"):
            entry = json.loads(line)
            # Keys are lowercase; "Friday" stays, proper nouns go by pos.
            word = (entry.get("word") or "").strip().lower()
            if (entry.get("lang_code") != "en" or not word or len(word) > 40
                    or entry.get("pos") in SKIP_POS):
                continue
            pos = part_of_speech(entry)
            for sense in entry.get("senses", []):
                tags = set(sense.get("tags") or [])
                if tags & UNCOMMON:
                    continue
                form_of = sense.get("form_of") or []
                if form_of or "form-of" in tags:
                    base = (form_of[0].get("word") if form_of else "") or ""
                    if base and base != word and base == base.lower():
                        redirects.setdefault(word, base)
                    continue
                accepted = False
                for raw in sense.get("glosses", [])[:1]:
                    gloss = convert(clean(raw))
                    if script.search(gloss) and len(gloss) <= 80:
                        glosses = entries.setdefault(word, {}).setdefault(pos, [])
                        accepted = True
                        if gloss not in glosses and len(glosses) < 8:
                            glosses.append(gloss)
                if not accepted:
                    continue
                found = examples.setdefault(word, {}).setdefault(pos, [])
                for example in sense.get("examples", []):
                    if len(found) >= 2:
                        break
                    pair = example_pair(example, word, script, convert)
                    if pair and all(pair[0] != seen[0] for seen in found):
                        found.append(pair)
    return {
        "source": f"https://{code}.wiktionary.org (via kaikki.org)",
        "license": "CC BY-SA 4.0",
        "entries": {
            word: [
                [pos, glosses, examples[word][pos]]
                if examples.get(word, {}).get(pos) else [pos, glosses]
                for pos, glosses in by_pos.items()
            ]
            for word, by_pos in sorted(entries.items())
        },
        # Words with their own meanings never redirect.
        "redirects": {
            word: base for word, base in sorted(redirects.items())
            if word not in entries
        },
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("code", choices=sorted(EDITIONS))
    parser.add_argument("--input", type=pathlib.Path, nargs="+")
    args = parser.parse_args()
    sources = args.input or download(args.code)
    data = build(args.code, sources)
    out = ROOT / "assets" / "dictionaries" / f"{args.code}.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(
        json.dumps(data, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    print(f"{len(data['entries'])} words, {len(data['redirects'])} redirects"
          f" -> {out} ({out.stat().st_size / 1e6:.2f} MB)")


if __name__ == "__main__":
    main()
