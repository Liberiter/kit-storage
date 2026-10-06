# 7장 본문이 자료에 대해 말하는 정수 주장 가운데 출력 블록에 찍히지 않는 것을 자료에서 직접 세어 고정하는
# 주장 케이스입니다.
# 받치는 자리: 7.1절 «문제 상황»의 「관측소가 여섯이면」(관측소 수 6), problem 2 해설의 「솔등은 구름많음과
# 맑음이 8일씩」·「갈숲은 흐림과 맑음이 9일씩」(출력에는 앞선 하늘 하나의 날수만 찍힌다).
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
rows_raw = [line.split("|") for line in lines]
info = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]


def sky_days(code, sky):
    return sum(1 for r in rows_raw if r[0] == code and r[5] == sky)


rows = [
    ("관측소 목록의 관측소 수", len(info)),
    ("솔등 11월 구름많음 날수", sky_days("SD", "구름많음")),
    ("솔등 11월 맑음 날수", sky_days("SD", "맑음")),
    ("갈숲 11월 흐림 날수", sky_days("GS", "흐림")),
    ("갈숲 11월 맑음 날수", sky_days("GS", "맑음")),
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
    print(pad(" " + label, label_width) + "|" + str(value).rjust(value_width))
