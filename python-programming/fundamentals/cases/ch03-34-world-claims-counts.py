# 3장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: «왜 배우나요»의 「최저기온 0도 이하·강수량 0mm 초과인 기록 26건, 모두 눈」,
# 3.1절 «문제 상황»의 「관측소 여섯 곳·한 달 치」, 3.1절 «왜 그럴까요»의 「< 로 적으면 25건」,
# 3.2절 «따라 하기» 4단계의 「180건 전부에 대 보면 어긋나는 기록 0건」.
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


def guess(low, rain):
    if rain > 0 and low <= 0:
        return "눈"
    if rain > 0:
        return "비"
    return "없음"


def matches(low, rain, sky):
    g = guess(low, rain)
    if g == "없음":
        return sky not in ("눈", "비")
    return sky == g


snowy = [r for r in record.values() if r[0] <= 0 and r[2] > 0]
rows = [
    ("관측 기록 줄 수", len(lines)),
    ("관측소 수", len({r[0] for r in rows_raw})),
    ("날짜 수", len({r[1] for r in rows_raw})),
    ("최저 0 이하이고 강수 0 초과인 기록 수", len(snowy)),
    ("그 가운데 하늘 상태가 눈이 아닌 기록 수", sum(1 for r in snowy if r[3] != "눈")),
    ("최저 0 미만이고 강수 0 초과인 기록 수", sum(1 for r in record.values() if r[0] < 0 and r[2] > 0)),
    ("3.2절 판정과 하늘 상태가 어긋난 기록 수", sum(1 for r in record.values() if not matches(r[0], r[2], r[3]))),
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
