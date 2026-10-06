# 2장 본문이 자료에서 옮겨 적은 소수 값을 자료에서 직접 뽑아 고정하는 주장 케이스입니다.
# 받치는 자리: 2.3절 «따라 하기» 3단계의 바람재 11월 1일 최저·최고 기온(-1.5도·7.8도),
# 2.3절 «practice»의 바람재 11월 4일 강수량 13.6mm, «도전하기» problem 2의 바람재
# 11월 4·5·6일 강수량(13.6·3.8·0.0mm). 값은 자료 파일의 글자를 float 로 읽어 그대로 냅니다.
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
record = {}
for line in lines:
    code, date, low, high, rain, sky = line.split("|")
    record[(code, date)] = (float(low), float(high), float(rain))

rows = [
    ("바람재 11월 1일 최저기온 도", record[("BJ", "2025-11-01")][0]),
    ("바람재 11월 1일 최고기온 도", record[("BJ", "2025-11-01")][1]),
    ("바람재 11월 4일 강수량 mm", record[("BJ", "2025-11-04")][2]),
    ("바람재 11월 5일 강수량 mm", record[("BJ", "2025-11-05")][2]),
    ("바람재 11월 6일 강수량 mm", record[("BJ", "2025-11-06")][2]),
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
