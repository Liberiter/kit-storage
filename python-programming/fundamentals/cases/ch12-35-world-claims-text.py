# 12장 본문 코드가 기록 파일에서 옮겨 적은 값 가운데 앞 장 케이스가 고정하지 않은 것을 자료에서 직접 만들어 고정하는
# 주장 케이스입니다. 줄은 본문 코드의 문자열 리터럴처럼 큰따옴표로, 리스트는 대괄호로 감싸 냅니다.
# 받치는 자리: exercise 3의 hg_records(하곡 11월 3·5일 줄, 그리고 4일 줄 — 본문은 이 줄의 | 를 빈칸으로 바꿔 적고 해설이
# 바른 줄을 싣는다), exercise 4의 하곡 11월 4일 줄, 12.2절 «흔한 실수»의 bj_sky(바람재 11월 1~10일 하늘 상태).
import unicodedata
from pathlib import Path

records = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


def line_of(code, day):
    found = [line for line in records if line.startswith(f"{code}|2025-11-{day:02d}|")]
    return found[0]


bj_sky = [
    line.split("|")[5]
    for line in records
    if line.startswith("BJ|") and int(line.split("|")[1][-2:]) <= 10
]
rows = [
    ("기록 파일 하곡 11월 3일 줄", quoted(line_of("HG", 3))),
    ("기록 파일 하곡 11월 4일 줄", quoted(line_of("HG", 4))),
    ("기록 파일 하곡 11월 5일 줄", quoted(line_of("HG", 5))),
    ("바람재 11월 1~10일 하늘 상태", "[" + ", ".join(quoted(s) for s in bj_sky) + "]"),
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
