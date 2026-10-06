# 6장 본문 코드가 자료에서 옮겨 적은 값(관측소 코드·이름·고도, 관측소별 11월 강수량 합계, 바람재
# 하늘 글자의 조각, 기록 파일의 줄, 현장 수첩의 줄)을 자료에서 직접 만들어 고정하는 주장 케이스입니다.
# 리스트는 본문 코드처럼 대괄호로, 딕셔너리는 중괄호로(본문이 여러 줄로 나눈 names 도 같은 항목·차례를
# 한 줄로), 줄과 글자는 본문 코드의 문자열 리터럴처럼 큰따옴표로 감싸 냅니다.
# 받치는 자리: 6.1절 «문제 상황»의 codes·names 리스트, 6.1절 «예측해 보기»·«따라 하기»·«흔한 실수»,
# exercise 3, 복습 exercise 1, problem 2의 names, «따라 하기» 4단계의 elevations, 복습 exercise 1의
# totals, 6.2절 «왜 그럴까요»·exercise 1의 바람재 상순·하순 하늘 글자, 6.1절 «따라 하기» 3단계·
# «왜 그럴까요»·exercise 1·2·4·problem 2의 기록 파일 줄, 6.2절 «따라 하기» 2단계·exercise 3·
# 복습 exercise 2·problem 1의 현장 수첩 줄.
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


def month_total(code):
    return sum(float(r[4]) for r in rows_raw if r[0] == code)


def sky_letters(code, first, last):
    picked = sorted(
        r for r in rows_raw if r[0] == code and first <= int(r[1][-2:]) <= last
    )
    return "".join(r[5][0] for r in picked)


codes = list(info)
rows = [
    ("관측소 코드 리스트", "[" + ", ".join(quoted(c) for c in codes) + "]"),
    ("관측소 이름 리스트", "[" + ", ".join(quoted(info[c]["name"]) for c in codes) + "]"),
    (
        "관측소 이름 딕셔너리",
        "{" + ", ".join(f"{quoted(c)}: {quoted(info[c]['name'])}" for c in codes) + "}",
    ),
    (
        "관측소 고도 딕셔너리",
        "{" + ", ".join(f"{quoted(c)}: {info[c]['elevation']}" for c in codes) + "}",
    ),
    (
        "관측소별 11월 강수량 합계",
        "{" + ", ".join(f"{quoted(c)}: {month_total(c):.1f}" for c in codes) + "}",
    ),
    ("바람재 1~10일 하늘 첫 글자", quoted(sky_letters("BJ", 1, 10))),
    ("바람재 21~30일 하늘 첫 글자", quoted(sky_letters("BJ", 21, 30))),
]
for day in [4, 5, 13, 14, 22, 23]:
    date = f"2025-11-{day:02d}"
    for line in lines:
        if line.split("|")[1] == date:
            rows.append((f"기록 파일 11월 {day}일 {line[:2]} 줄", quoted(line)))
for day in [2, 3, 4]:
    date = f"2025-11-{day:02d}"
    n = 0
    for line in log:
        if line.split("|")[1].strip() == date:
            n = n + 1
            rows.append((f"현장 수첩 11월 {day}일 줄 {n}", quoted(line)))



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
