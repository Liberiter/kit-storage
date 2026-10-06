# 3장 본문이 자료에서 옮겨 적은 소수 값을 자료에서 직접 뽑아 고정하는 주장 케이스입니다.
# 받치는 자리: «왜 배우나요»·3.1절·3.2절·복습 exercise 1의 11월 17일 최저기온(갈숲·솔등·너미),
# 3.1절 practice와 exercise 1의 하곡 11월 17일, 3.1절 «따라 하기» 3단계·problem 1의 솔등 11월
# 14일·솔등 11월 17일·너미 11월 22일, 3.1절 «흔한 실수» 둘째의 하곡 11월 6일, 3.2절 practice의
# 하곡 11월 4일, exercise 3의 바람재 11월 2일·7일, exercise 4의 물레 11월 17일, problem 2의
# 솔등 11월 13일·갈숲 11월 4일·솔등 11월 17일. 값은 자료 파일의 글자를 float 로 읽어 그대로 냅니다.
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
record = {}
for code, date, low, high, rain, sky in rows_raw:
    record[(info[code]["name"], date)] = (float(low), float(high), float(rain), sky)

rows = [
    ("갈숲 11월 17일 최저기온 도", record[("갈숲", "2025-11-17")][0]),
    ("솔등 11월 17일 최저기온 도", record[("솔등", "2025-11-17")][0]),
    ("너미 11월 17일 최저기온 도", record[("너미", "2025-11-17")][0]),
    ("하곡 11월 17일 최저기온 도", record[("하곡", "2025-11-17")][0]),
    ("하곡 11월 17일 최고기온 도", record[("하곡", "2025-11-17")][1]),
    ("하곡 11월 17일 강수량 mm", record[("하곡", "2025-11-17")][2]),
    ("물레 11월 17일 최저기온 도", record[("물레", "2025-11-17")][0]),
    ("솔등 11월 17일 강수량 mm", record[("솔등", "2025-11-17")][2]),
    ("솔등 11월 14일 최저기온 도", record[("솔등", "2025-11-14")][0]),
    ("솔등 11월 14일 강수량 mm", record[("솔등", "2025-11-14")][2]),
    ("너미 11월 22일 최저기온 도", record[("너미", "2025-11-22")][0]),
    ("너미 11월 22일 강수량 mm", record[("너미", "2025-11-22")][2]),
    ("하곡 11월 6일 최저기온 도", record[("하곡", "2025-11-06")][0]),
    ("하곡 11월 4일 최저기온 도", record[("하곡", "2025-11-04")][0]),
    ("하곡 11월 4일 강수량 mm", record[("하곡", "2025-11-04")][2]),
    ("바람재 11월 2일 최저기온 도", record[("바람재", "2025-11-02")][0]),
    ("바람재 11월 2일 최고기온 도", record[("바람재", "2025-11-02")][1]),
    ("바람재 11월 7일 최저기온 도", record[("바람재", "2025-11-07")][0]),
    ("바람재 11월 7일 최고기온 도", record[("바람재", "2025-11-07")][1]),
    ("솔등 11월 13일 최저기온 도", record[("솔등", "2025-11-13")][0]),
    ("솔등 11월 13일 강수량 mm", record[("솔등", "2025-11-13")][2]),
    ("갈숲 11월 4일 최저기온 도", record[("갈숲", "2025-11-04")][0]),
    ("갈숲 11월 4일 강수량 mm", record[("갈숲", "2025-11-04")][2]),
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
