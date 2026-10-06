# 11장 본문이 자료에 대해 말하는 정수 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다.
# 받치는 자리: 들어가며의 「26줄 가운데」와 problem 1의 「현장 수첩 26줄 전부」(수첩 줄 수), 11.2절 «문제 상황»의
# 「이 수첩에서는 그런 칸이 모두 「결측」이지만」(결측 줄 수와, 결측이 아닌데 수로 바꿀 수 없는 칸 0), problem 1
# 해설의 「3일의 `pt` 줄과 4일의 `PT` 줄」(PT 줄 2), exercise 3 해설의 「기록 파일의 줄은 칸이 여섯」·「현장 수첩 줄은
# 관측소·날짜·강수량 세 칸뿐」(칸 수가 그와 다른 줄 0), 본문 코드가 옮겨 적은 날짜별 줄 수(11월 1·2일 6, 3·4일 7),
# 들어가며의 「현장 수첩에는 물레(`MR`)의 11월 1~4일 강수량이 모두 `0.0` 으로 적혀 있습니다」와 11.1절 «따라 하기» 3단계·11.3절 «따라 하기»
# 2·3단계의 같은 사실(수첩의 물레 줄 4, 그 가운데 강수량이 0보다 큰 줄 0), 관측소 목록이 여섯 곳이고 PT 가 없다는 것(6, 0).
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
records = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]


def is_number(text):
    try:
        float(text)
    except ValueError:
        return False
    return True


def day_lines(day):
    return sum(1 for c in cells if c[1] == f"2025-11-{day:02d}")


rows = [
    ("현장 수첩의 줄 수", len(cells)),
    ("현장 수첩에서 강수량 칸이 결측인 줄 수", sum(1 for c in cells if c[2] == "결측")),
    (
        "결측이 아닌데 수로 바꿀 수 없는 칸 수",
        sum(1 for c in cells if c[2] != "결측" and not is_number(c[2])),
    ),
    ("현장 수첩에서 코드가 PT 인 줄 수", sum(1 for c in cells if c[0].upper() == "PT")),
    ("현장 수첩 줄 가운데 칸이 셋이 아닌 줄 수", sum(1 for c in cells if len(c) != 3)),
    (
        "기록 파일 줄 가운데 칸이 여섯이 아닌 줄 수",
        sum(1 for line in records if len(line.split("|")) != 6),
    ),
    ("현장 수첩 11월 1일 줄 수", day_lines(1)),
    ("현장 수첩 11월 2일 줄 수", day_lines(2)),
    ("현장 수첩 11월 3일 줄 수", day_lines(3)),
    ("현장 수첩 11월 4일 줄 수", day_lines(4)),
    ("현장 수첩에서 물레(MR) 줄 수", sum(1 for c in cells if c[0].upper() == "MR")),
    (
        "물레 줄 가운데 강수량이 0보다 큰 줄 수",
        sum(1 for c in cells if c[0].upper() == "MR" and float(c[2]) > 0),
    ),
    ("관측소 목록의 관측소 수", len(info)),
    ("관측소 목록에 PT 가 있는 수", sum(1 for code in info if code == "PT")),
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
