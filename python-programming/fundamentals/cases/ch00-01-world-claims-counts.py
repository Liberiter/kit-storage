# 0장이 자료에 대해 말하는 수치를 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: 0.3절 「관측소 여섯 곳이 한 달 동안 ... 기록 180건」,
# 0.4절 구축 화면의 「자료 파일 준비: 관측 기록 180건」.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
tree = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))

rows = [
    ("관측 기록 줄 수", len(lines)),
    ("관측 기록에 나오는 관측소 수", len({line.split("|")[0] for line in lines})),
    ("관측 기록에 나오는 날짜 수", len({line.split("|")[1] for line in lines})),
    ("관측소 정보 파일의 관측소 수", len(tree["stations"])),
]


def width(text):
    return sum(2 if unicodedata.east_asian_width(ch) in "WF" else 1 for ch in text)


def pad(text, size):
    return text + " " * (size - width(text))


label_width = max(width(label) for label, _ in rows) + 2
value_width = 7
print(pad(" 주장", label_width) + "|" + pad(" 실측값", value_width))
print("-" * label_width + "+" + "-" * value_width)
for label, value in rows:
    print(pad(" " + label, label_width) + "|" + str(value).rjust(value_width))
