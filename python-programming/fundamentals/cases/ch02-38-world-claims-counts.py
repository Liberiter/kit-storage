# 2장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: 2.1절의 여섯 관측소 고도(솔등 447·갈숲 355·너미 158·하곡 93·바람재 612·물레 238)와
# 「바람재가 가장 높고 하곡이 가장 낮다」(그보다 높은·낮은 관측소 0곳), 2.1절 «따라 하기»
# 4단계의 「날마다 관측소 여섯 곳이 한 건씩」과 11월 1·2·3일까지 쌓인 기록 6·12·18건,
# 2.2절 «따라 하기» 3단계의 「여섯 관측소」.
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
dates = sorted({line.split("|")[1] for line in lines})
per_day = {d: sum(1 for line in lines if line.split("|")[1] == d) for d in dates}
pairs = {(line.split("|")[0], line.split("|")[1]) for line in lines}

rows = [
    ("관측소 정보 파일의 관측소 수", len(info)),
    ("솔등 고도 m", height["솔등"]),
    ("갈숲 고도 m", height["갈숲"]),
    ("너미 고도 m", height["너미"]),
    ("하곡 고도 m", height["하곡"]),
    ("바람재 고도 m", height["바람재"]),
    ("물레 고도 m", height["물레"]),
    ("바람재보다 높은 관측소 수", sum(1 for h in height.values() if h > height["바람재"])),
    ("하곡보다 낮은 관측소 수", sum(1 for h in height.values() if h < height["하곡"])),
    ("기록 수가 6이 아닌 날짜 수", sum(1 for n in per_day.values() if n != 6)),
    ("같은 관측소 같은 날짜가 겹친 기록 수", len(lines) - len(pairs)),
    ("11월 1일까지의 기록 수", sum(n for d, n in per_day.items() if d <= "2025-11-01")),
    ("11월 2일까지의 기록 수", sum(n for d, n in per_day.items() if d <= "2025-11-02")),
    ("11월 3일까지의 기록 수", sum(n for d, n in per_day.items() if d <= "2025-11-03")),
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
