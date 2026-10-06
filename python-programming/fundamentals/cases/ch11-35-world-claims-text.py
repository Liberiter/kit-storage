# 11장 본문 코드가 자료에서 옮겨 적은 값(관측소 이름·고도, 현장 수첩의 줄, 관측소별 수첩 강수량 칸,
# 결측을 뺀 강수량 리스트)을 자료에서 직접 만들어 고정하는 주장 케이스입니다. 리스트는 본문 코드처럼
# 대괄호로, 딕셔너리는 중괄호로(본문이 여러 줄로 나눈 것도 같은 항목·차례를 한 줄로), 줄과 글자는 본문
# 코드의 문자열 리터럴처럼 큰따옴표로 감싸 냅니다.
# 받치는 자리: 본문 전체의 names(관측소 이름), 11.3절 «practice»의 elevations, 11.1~11.3절과 연습하기의
# 현장 수첩 줄(lines), 11.3절의 notes, 11.1절의 texts·sd_texts·mr, 11.3절 «왜 그럴까요»·exercise 4·
# 복습 exercise 1의 관측소별 강수량 리스트.
import json
import unicodedata
from pathlib import Path

info = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]
log = [
    line
    for line in Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
cells = [[part.strip() for part in line.split("|")] for line in log]
codes = list(info)


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


def texts_of(code):
    picked = sorted((c[1], c[2]) for c in cells if c[0].upper() == code)
    return [text for _, text in picked]


def amounts_of(code):
    return [float(text) for text in texts_of(code) if text != "결측"]


rows = [
    (
        "관측소 이름 딕셔너리",
        "{" + ", ".join(f"{quoted(c)}: {quoted(info[c]['name'])}" for c in codes) + "}",
    ),
    (
        "관측소 고도 딕셔너리",
        "{" + ", ".join(f"{quoted(c)}: {info[c]['elevation']}" for c in codes) + "}",
    ),
    (
        "관측소별 수첩 강수량 칸",
        "{"
        + ", ".join(
            f"{quoted(c)}: [" + ", ".join(quoted(t) for t in texts_of(c)) + "]"
            for c in codes
        )
        + "}",
    ),
]
for code in ["BJ", "SD", "HG", "MR"]:
    rows.append((f"{code} 결측을 뺀 강수량 리스트", str(amounts_of(code))))
for day in [1, 2, 3, 4]:
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
