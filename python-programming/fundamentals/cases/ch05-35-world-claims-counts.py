# 5장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: 5.1절 «따라 하기» 4단계·practice의 바람재·솔등 상순(1~10일) 비나 눈이 온 날 수,
# 5.1절 «왜 그럴까요»의 「바람재 11월 15~21일은 비나 눈이 한 번도 오지 않았다」,
# 5.3절의 「현장 수첩의 11월 1일·4일 줄은 여섯 관측소가 한 줄씩」과 «왜 그럴까요»의
# 「현장 수첩의 줄은 모두 | 로 나뉜 세 칸」, problem 2의 「기록 파일 한 줄은 | 로 나뉜 여섯 칸」과
# 채점 포인트의 「하곡은 상순 최저기온이 모두 0도보다 높다」.
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
log = Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()
log_rows = [line.split("|") for line in log]


def rain_days(code, first, last):
    return sum(
        1
        for r in rows_raw
        if r[0] == code and first <= int(r[1][-2:]) <= last and float(r[4]) > 0
    )


def log_count(date):
    return sum(
        1
        for r in log_rows
        if r[1].strip() == date and r[0].strip().upper() in info
    )


def log_codes(date):
    return len({r[0].strip().upper() for r in log_rows if r[1].strip() == date} & set(info))


rows = [
    ("바람재 1~10일 강수가 있었던 날 수", rain_days("BJ", 1, 10)),
    ("솔등 1~10일 강수가 있었던 날 수", rain_days("SD", 1, 10)),
    ("바람재 15~21일 강수가 있었던 날 수", rain_days("BJ", 15, 21)),
    ("현장 수첩 11월 1일 여섯 관측소의 줄 수", log_count("2025-11-01")),
    ("현장 수첩 11월 1일 줄의 관측소 가짓수", log_codes("2025-11-01")),
    ("현장 수첩 11월 4일 여섯 관측소의 줄 수", log_count("2025-11-04")),
    ("현장 수첩 11월 4일 줄의 관측소 가짓수", log_codes("2025-11-04")),
    ("현장 수첩에서 칸이 셋이 아닌 줄 수", sum(1 for r in log_rows if len(r) != 3)),
    ("기록 파일에서 칸이 여섯이 아닌 줄 수", sum(1 for r in rows_raw if len(r) != 6)),
    (
        "하곡 1~10일 최저기온이 0 이하인 날 수",
        sum(
            1
            for r in rows_raw
            if r[0] == "HG" and int(r[1][-2:]) <= 10 and float(r[2]) <= 0
        ),
    ),
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
