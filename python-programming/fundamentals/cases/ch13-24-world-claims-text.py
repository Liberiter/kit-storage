# 13장 본문 코드가 기록 파일에서 옮겨 적은 값 가운데 앞 장 케이스가 고정하지 않은 것을 자료에서 직접 만들어 고정하는
# 주장 케이스입니다. 수는 본문 코드의 리스트처럼 대괄호 안에 쉼표로, 날짜는 큰따옴표로 감싸 냅니다.
# 받치는 자리: 13.1절 «문제 상황»·«예측해 보기»·«따라 하기» 1단계·«흔한 실수»의 bj_low(바람재 11월 1~10일 최저기온),
# 13.1절 practice 1의 sd_low·sd_high(솔등 11월 1~10일 최저·최고기온), 13.2절 «따라 하기» 3단계와 복습 exercise 2의
# rainy_dates(바람재 11월 1~10일 가운데 강수량이 0보다 큰 날), 13.2절 practice 1의 sd_rainy(솔등의 같은 날),
# 복습 exercise 2의 first_snow(바람재 11월 기록에서 하늘 상태가 눈인 첫 날).
import unicodedata
from pathlib import Path

records = [
    line.split("|")
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]


def first_ten(code):
    return [cells for cells in records if cells[0] == code and int(cells[1][-2:]) <= 10]


def numbers(cells_list, index):
    return "[" + ", ".join(cells[index] for cells in cells_list) + "]"


def dates(cells_list):
    return "[" + ", ".join('"' + cells[1] + '"' for cells in cells_list) + "]"


bj = first_ten("BJ")
sd = first_ten("SD")
bj_snow = [cells for cells in records if cells[0] == "BJ" and cells[5] == "눈"]
rows = [
    ("바람재 11월 1~10일 최저기온", numbers(bj, 2)),
    ("솔등 11월 1~10일 최저기온", numbers(sd, 2)),
    ("솔등 11월 1~10일 최고기온", numbers(sd, 3)),
    ("바람재 11월 1~10일 강수량이 있는 날", dates([c for c in bj if float(c[4]) > 0])),
    ("솔등 11월 1~10일 강수량이 있는 날", dates([c for c in sd if float(c[4]) > 0])),
    ("바람재 11월 하늘 상태가 눈인 첫 날", '"' + min(c[1] for c in bj_snow) + '"'),
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
