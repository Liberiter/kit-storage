# 5장 본문 코드가 자료에서 옮겨 적은 값(강수량·기온 리스트, 현장 수첩의 줄, 기록 파일의 줄)을
# 자료에서 직접 만들어 고정하는 주장 케이스입니다. 리스트는 본문 코드의 리스트처럼 대괄호로,
# 줄은 본문 코드의 문자열 리터럴처럼 큰따옴표로 감싸 냅니다.
# 받치는 자리: 5.1절(문제 상황의 1~5일, 예측해 보기·따라 하기의 bj_rain·bj_high, 왜 그럴까요의
# dry_week, practice의 sd_rain), 5.2절의 bj_rain, exercise 2·4의 nm_high·nm_low, 복습 exercise 1의
# bj_rain, 5.3절·practice·problem 1의 현장 수첩 줄, 5.3절 «흔한 실수»와 problem 2의 기록 파일 줄.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
rows_raw = [line.split("|") for line in lines]
log = Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()


def series(code, field, first, last):
    picked = sorted(
        r for r in rows_raw if r[0] == code and first <= int(r[1][-2:]) <= last
    )
    return "[" + ", ".join(r[field] for r in picked) + "]"


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


rows = [
    ("바람재 1~5일 강수량", series("BJ", 4, 1, 5)),
    ("바람재 1~10일 강수량", series("BJ", 4, 1, 10)),
    ("바람재 1~10일 최고기온", series("BJ", 3, 1, 10)),
    ("바람재 15~21일 강수량", series("BJ", 4, 15, 21)),
    ("솔등 1~10일 강수량", series("SD", 4, 1, 10)),
    ("너미 1~10일 최고기온", series("NM", 3, 1, 10)),
    ("너미 1~10일 최저기온", series("NM", 2, 1, 10)),
]
for n, line in enumerate(line for line in log if "2025-11-01" in line):
    rows.append((f"현장 수첩 11월 1일 줄 {n + 1}", quoted(line)))
for n, line in enumerate(
    line for line in log if "2025-11-04" in line and not line.strip().lower().startswith("pt")
):
    rows.append((f"현장 수첩 11월 4일 줄 {n + 1}", quoted(line)))
for day in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 14]:
    line = [x for x in lines if x.startswith(f"BJ|2025-11-{day:02d}|")][0]
    rows.append((f"기록 파일 바람재 11월 {day}일 줄", quoted(line)))


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
