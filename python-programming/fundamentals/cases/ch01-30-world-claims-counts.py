# 1장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: «왜 배우나요»의 관측소 여섯 곳·30일·기록 180건, 1.1절 «practice»의 솔등
# 전송 주기 10분, 1.2절의 고도(바람재 612·하곡 93·솔등 447·너미 158·갈숲 355·물레 238)와
# 「가장 높은 곳·가장 낮은 곳」, «도전하기» problem 1 지문의 다섯 고도.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
info = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]
height = {s["name"]: s["elevation"] for s in info.values()}
by_name = {s["name"]: s for s in info.values()}

rows = [
    ("관측소 정보 파일의 관측소 수", len(info)),
    ("관측 기록 줄 수", len(lines)),
    ("관측 기록에 나오는 날짜 수", len({line.split("|")[1] for line in lines})),
    ("관측 기록에 나오는 관측소 수", len({line.split("|")[0] for line in lines})),
    ("바람재 고도 m", height["바람재"]),
    ("하곡 고도 m", height["하곡"]),
    ("솔등 고도 m", height["솔등"]),
    ("너미 고도 m", height["너미"]),
    ("갈숲 고도 m", height["갈숲"]),
    ("물레 고도 m", height["물레"]),
    ("바람재보다 높은 관측소 수", sum(1 for h in height.values() if h > height["바람재"])),
    ("하곡보다 낮은 관측소 수", sum(1 for h in height.values() if h < height["하곡"])),
    ("솔등 전송 주기 분", by_name["솔등"]["interval_min"]),
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
