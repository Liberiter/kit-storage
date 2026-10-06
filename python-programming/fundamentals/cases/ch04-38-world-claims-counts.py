# 4장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: «왜 배우나요»와 4.2·4.3절의 「관측소 여섯 곳이 날마다 한 건씩 — 하루 여섯 건, 30일, 180건」,
# 4.1절 «문제 상황»의 「하늘 상태 다섯 가지의 첫 글자가 서로 다르다」와 「하늘 상태가 비나 눈인 날 =
# 강수가 있던 날」, 4.1절 «따라 하기»·practice의 바람재·솔등 날수, exercise 2 해설의 「눈 온 기록 26건」.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
info = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]
rows_raw = [line.split("|") for line in lines]
dates = sorted({r[1] for r in rows_raw})
skies = {r[5] for r in rows_raw}


def station(name):
    return [r for r in rows_raw if info[r[0]]["name"] == name]


def wet(r):
    return r[5] in ("비", "눈")


rows = [
    ("관측 기록 줄 수", len(lines)),
    ("관측소 수", len({r[0] for r in rows_raw})),
    ("날짜 수", len(dates)),
    ("기록 수가 6이 아닌 날짜 수", sum(1 for d in dates if sum(1 for r in rows_raw if r[1] == d) != 6)),
    ("관측소마다 날짜가 겹친 기록 수", len(rows_raw) - len({(r[0], r[1]) for r in rows_raw})),
    ("하늘 상태 가짓수", len(skies)),
    ("하늘 상태 첫 글자 가짓수", len({s[0] for s in skies})),
    ("하늘이 비나 눈인데 강수가 0인 기록 수", sum(1 for r in rows_raw if wet(r) and float(r[4]) <= 0)),
    ("강수가 있는데 하늘이 비도 눈도 아닌 기록 수", sum(1 for r in rows_raw if not wet(r) and float(r[4]) > 0)),
    ("하늘 상태가 눈인 기록 수", sum(1 for r in rows_raw if r[5] == "눈")),
    ("바람재 눈 온 날 수", sum(1 for r in station("바람재") if r[5] == "눈")),
    ("바람재 비나 눈이 온 날 수", sum(1 for r in station("바람재") if wet(r))),
    ("바람재 맑은 날 수", sum(1 for r in station("바람재") if r[5] == "맑음")),
    ("솔등 비나 눈이 온 날 수", sum(1 for r in station("솔등") if wet(r))),
    ("솔등 맑은 날 수", sum(1 for r in station("솔등") if r[5] == "맑음")),
    ("솔등 전송 주기 분", info["SD"]["interval_min"]),
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
