# 9장 본문 코드가 자료에서 옮겨 적은 값 가운데 앞 장 주장 케이스가 고정하지 않은 것을 자료에서 직접 만들어 고정하는
# 주장 케이스입니다. 튜플은 본문 코드처럼 괄호로, 줄과 글자는 본문 코드의 문자열 리터럴처럼 큰따옴표로 감싸 냅니다.
# 받치는 자리: 관측소의 (코드, 이름, 고도) 튜플 — 9.2절 «문제 상황»·«예측해 보기»·«따라 하기» 1~3단계의 바람재,
# 9.2절 practice 1의 너미, problem 2의 stations 여섯 튜플(관측소 자료 파일에 적힌 차례). 바람재 11월 8·9·10일 기록
# 파일 줄 — 9.3절 «흔한 실수»의 「8일·9일 강수량 0.1mm·0.2mm, 10일 0.3mm」와 exercise 4의 「바람재 8일 + 9일」.
# 기록 파일 강수량 칸의 소수점 아래 자릿수별 칸 수 — 9.3절 «흔한 실수»의 「자료의 강수량이 0.1mm 단위」와 exercise 4
# 해설의 「자료의 단위(0.1mm)」. 자릿수를 키, 칸 수를 값으로 하는 딕셔너리로 냅니다.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
stations = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


def as_tuple(code):
    info = stations[code]
    return "(" + ", ".join([quoted(code), quoted(info["name"]), str(info["elevation"])]) + ")"


rows = [("관측소 자료 파일의 코드 차례", "[" + ", ".join(quoted(c) for c in stations) + "]")]
for code in stations:
    rows.append((f"{code} 관측소 튜플", as_tuple(code)))
for day in ["08", "09", "10"]:
    picked = [line for line in lines if line.startswith(f"BJ|2025-11-{day}|")]
    rows.append((f"기록 파일 바람재 11월 {int(day)}일 줄", quoted(picked[0])))

places = {}
for line in lines:
    rain = line.split("|")[4]
    digits = len(rain.split(".")[1]) if "." in rain else 0
    places[digits] = places.get(digits, 0) + 1
rows.append(("기록 파일 강수량 칸의 소수점 아래 자릿수별 칸 수", str(places)))


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
