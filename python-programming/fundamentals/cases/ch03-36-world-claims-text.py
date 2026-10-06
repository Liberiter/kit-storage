# 3장 본문이 자료에 대해 말하는 글자 주장을 자료에서 직접 뽑아 고정하는 주장 케이스입니다.
# 받치는 자리: 3.1절 «따라 하기» 3단계의 「세 기록은 차례로 눈·맑음·비」, 3.1절 «왜 그럴까요»의
# 「< 로 적으면 솔등 11월 14일 기록이 빠진다」, 3.1절 «흔한 실수» 둘째의 「하곡 11월 6일은 맑음」,
# 3.2절 «따라 하기» 4단계의 「솔등 11월 14일은 눈」과 「강수가 없던 날은 맑음·흐림·구름많음」,
# 3.2절 practice의 「하곡 11월 4일은 비」.
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
record = {}
for code, date, low, high, rain, sky in rows_raw:
    record[(info[code]["name"], date)] = (float(low), float(high), float(rain), sky)

dropped = [
    f"{n} {d}"
    for (n, d), r in sorted(record.items())
    if r[0] <= 0 and r[2] > 0 and not r[0] < 0
]
rows = [
    ("솔등 11월 14일 하늘 상태", record[("솔등", "2025-11-14")][3]),
    ("솔등 11월 17일 하늘 상태", record[("솔등", "2025-11-17")][3]),
    ("너미 11월 22일 하늘 상태", record[("너미", "2025-11-22")][3]),
    ("하곡 11월 6일 하늘 상태", record[("하곡", "2025-11-06")][3]),
    ("하곡 11월 4일 하늘 상태", record[("하곡", "2025-11-04")][3]),
    ("< 로 적으면 빠지는 눈 기록", ", ".join(dropped)),
    ("강수가 없던 날의 하늘 상태", ", ".join(sorted({r[3] for r in record.values() if r[2] <= 0}))),
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
