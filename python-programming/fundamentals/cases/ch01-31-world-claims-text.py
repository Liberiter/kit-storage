# 1장 본문이 자료에 대해 말하는 글자·날짜 주장을 자료에서 직접 뽑아 고정하는 주장 케이스입니다.
# 받치는 자리: «왜 배우나요»의 「2025년 11월 한 달」, 1.1절 «practice»의 「솔등은 자동
# 관측소」, 1.2절 «따라 하기» 1단계의 「가장 높은 곳은 바람재, 가장 낮은 곳은 하곡」,
# 1.2절 «practice»와 «도전하기» problem 1의 「나머지 관측소 넷」의 이름.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
info = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]
ordered = sorted(info.values(), key=lambda s: -s["elevation"])
dates = sorted({line.split("|")[1] for line in lines})
by_name = {s["name"]: s for s in info.values()}

rows = [
    ("관측 기록의 첫 날짜", dates[0]),
    ("관측 기록의 마지막 날짜", dates[-1]),
    ("가장 높은 관측소", ordered[0]["name"]),
    ("가장 낮은 관측소", ordered[-1]["name"]),
    ("바람재 하곡 밖의 관측소", " ".join(sorted(s["name"] for s in ordered[1:-1]))),
    ("솔등 관측소 종류", by_name["솔등"]["kind"]),
]


def width(text):
    return sum(2 if unicodedata.east_asian_width(ch) in "WF" else 1 for ch in text)


def pad(text, size):
    return text + " " * (size - width(text))


label_width = max(width(label) for label, _ in rows) + 2
value_width = max(width(" 실측값"), max(width(str(v)) for _, v in rows) + 1) + 1
print(pad(" 주장", label_width) + "|" + pad(" 실측값", value_width))
print("-" * label_width + "+" + "-" * value_width)
for label, value in rows:
    print(pad(" " + label, label_width) + "|" + pad(" " + str(value), value_width))
