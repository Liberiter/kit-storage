# 6장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: 6.1절 «문제 상황»·«따라 하기» 4단계와 6.2절 «따라 하기» 3단계의 「관측소 목록은
# 여섯 곳」, 6.2절 «따라 하기» 2·3단계와 exercise 3·problem 1의 「PT 는 관측소 목록에 없는 코드」,
# 들어가며·6.1절 «따라 하기» 3단계의 「기록 파일에는 날마다 여섯 관측소의 줄」, 6.2절 «따라 하기»
# 2단계·복습 exercise 2의 「현장 수첩 11월 3·4일 줄 열네 개」, exercise 3의 「11월 4일 줄 일곱 개」,
# problem 1의 「11월 2·3일 줄 열세 개」.
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
log = [
    line
    for line in Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]


def log_lines(*dates):
    return sum(1 for line in log if line.split("|")[1].strip() in dates)


per_date = {}
for r in rows_raw:
    per_date[r[1]] = per_date.get(r[1], 0) + 1

rows = [
    ("관측소 목록의 관측소 수", len(info)),
    ("관측소 목록에 PT 가 있는 수", sum(1 for code in info if code == "PT")),
    ("기록 파일에서 줄이 여섯이 아닌 날짜 수", sum(1 for n in per_date.values() if n != 6)),
    ("현장 수첩 11월 3·4일 줄 수", log_lines("2025-11-03", "2025-11-04")),
    ("현장 수첩 11월 4일 줄 수", log_lines("2025-11-04")),
    ("현장 수첩 11월 2·3일 줄 수", log_lines("2025-11-02", "2025-11-03")),
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
