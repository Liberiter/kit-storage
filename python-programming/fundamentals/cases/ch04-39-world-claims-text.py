# 4장 본문이 자료에서 옮겨 적은 글자(하늘 상태를 이은 문자열, 날짜별 관측소 수를 이은 숫자 문자열)를
# 자료에서 직접 만들어 고정하는 주장 케이스입니다. 문자열 행은 본문 코드의 리터럴처럼 큰따옴표로 감싸 냅니다.
# 받치는 자리: 4.1절의 bj_sky(바람재 30일)·week_sky(바람재 1~7일)·«문제 상황»의 11월 4~6일 하늘 상태,
# 4.1절 practice·복습 exercise 1의 sd_sky, 4.1절 «문제 상황»의 하늘 상태 다섯 가지와 첫 글자,
# exercise 2의 snow_stations, 복습 exercise 2의 freezing, problem 1의 두 문자열(bj_sky·sd_sky와 같다),
# exercise 3의 「2025년 11월의 일요일」.
import datetime
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
dates = sorted({r[1] for r in rows_raw})
skies = sorted({r[5] for r in rows_raw})


def sky_text(name, first=1, last=30):
    rows = sorted(r for r in rows_raw if info[r[0]]["name"] == name)
    return "".join(r[5][0] for r in rows if first <= int(r[1][-2:]) <= last)


def per_day(test):
    return "".join(str(sum(1 for r in rows_raw if r[1] == d and test(r))) for d in dates)


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


def sky_on(name, day):
    return [r[5] for r in rows_raw if info[r[0]]["name"] == name and r[1] == f"2025-11-{day:02d}"][0]


sundays = [
    str(d)
    for d in range(1, 31)
    if datetime.date(2025, 11, d).weekday() == 6
]
rows = [
    ("바람재 30일 하늘 첫 글자 문자열", quoted(sky_text("바람재"))),
    ("바람재 1~7일 하늘 첫 글자 문자열", quoted(sky_text("바람재", 1, 7))),
    ("솔등 30일 하늘 첫 글자 문자열", quoted(sky_text("솔등"))),
    ("바람재 11월 4, 5, 6일 하늘 상태", ", ".join(sky_on("바람재", d) for d in (4, 5, 6))),
    ("하늘 상태 다섯 가지", ", ".join(skies)),
    ("그 첫 글자", ", ".join(s[0] for s in skies)),
    ("날짜별 눈 온 관측소 수 문자열", quoted(per_day(lambda r: r[5] == "눈"))),
    ("날짜별 최저 0 이하 관측소 수 문자열", quoted(per_day(lambda r: float(r[2]) <= 0))),
    ("첫 날짜", dates[0]),
    ("마지막 날짜", dates[-1]),
    ("2025년 11월의 일요일", ", ".join(sundays)),
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
