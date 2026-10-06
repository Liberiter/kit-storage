# 7장 본문 코드가 자료에서 옮겨 적은 값(관측소 이름, 11월 1일 여섯 관측소의 최저·최고기온, 관측소별 날짜
# 구간의 최저·최고기온·강수량, 하늘 첫 글자 문자열, 기록 파일·현장 수첩의 줄)을 자료에서 직접 만들어 고정하는
# 주장 케이스입니다. 리스트는 본문 코드처럼 대괄호로, 줄과 글자는 본문 코드의
# 문자열 리터럴처럼 큰따옴표로 감싸 냅니다.
# 받치는 자리: 7.2절 «문제 상황»·«예측해 보기»·«따라 하기»·«흔한 실수»의 11월 1일 최저·최고기온과 바람재 1~5일 최저·최고기온,
# 7.2절 «따라 하기» 3단계·7.3절 practice·복습 exercise 2의 바람재 하늘 문자열, 7.3절 practice의 솔등 하늘 문자열,
# 7.2절 practice·exercise 4·problem 1의 1~10일 강수량, 7.3절 «문제 상황»·«예측해 보기»·«따라 하기» 2단계의
# 11월 1일 여섯 관측소 목록, 7.3절 «따라 하기» 3단계·exercise 1의 바람재 1~5일 강수량, exercise 2·3의 바람재
# 11월 1일 줄, 복습 exercise 1의 바람재 1~15일 강수량, 복습 exercise 2의 현장 수첩 11월 1일 줄,
# problem 1의 바람재·너미 1~10일 최저·최고기온·강수량, problem 2의 여섯 관측소 하늘 문자열.
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


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


def picked(code, first, last):
    return sorted(
        r for r in rows_raw if r[0] == code and first <= int(r[1][-2:]) <= last
    )


def column(code, first, last, index):
    return "[" + ", ".join(r[index] for r in picked(code, first, last)) + "]"


def sky_letters(code):
    return "".join(r[5][0] for r in picked(code, 1, 30))


codes = ["BJ", "SD", "NM", "HG", "MR", "GS"]
day1 = [picked(c, 1, 1)[0] for c in codes]
rows = [
    ("관측소 이름 리스트", "[" + ", ".join(quoted(info[c]["name"]) for c in codes) + "]"),
    ("11월 1일 최저기온 리스트", "[" + ", ".join(r[2] for r in day1) + "]"),
    ("11월 1일 최고기온 리스트", "[" + ", ".join(r[3] for r in day1) + "]"),
    ("바람재 1~5일 최저기온", column("BJ", 1, 5, 2)),
    ("바람재 1~5일 최고기온", column("BJ", 1, 5, 3)),
    ("바람재 1~5일 강수량", column("BJ", 1, 5, 4)),
    ("바람재 1~10일 최저기온", column("BJ", 1, 10, 2)),
    ("바람재 1~10일 최고기온", column("BJ", 1, 10, 3)),
    ("바람재 1~10일 강수량", column("BJ", 1, 10, 4)),
    ("바람재 1~15일 강수량", column("BJ", 1, 15, 4)),
    ("솔등 1~10일 강수량", column("SD", 1, 10, 4)),
    ("너미 1~10일 최저기온", column("NM", 1, 10, 2)),
    ("너미 1~10일 최고기온", column("NM", 1, 10, 3)),
    ("너미 1~10일 강수량", column("NM", 1, 10, 4)),
]
for code in codes:
    rows.append((f"{info[code]['name']} 30일 하늘 첫 글자", quoted(sky_letters(code))))
rows.append(("기록 파일 바람재 11월 1일 줄", quoted("|".join(picked("BJ", 1, 1)[0]))))
n = 0
for line in log:
    if line.split("|")[1].strip() == "2025-11-01":
        n = n + 1
        rows.append((f"현장 수첩 11월 1일 줄 {n}", quoted(line)))


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
