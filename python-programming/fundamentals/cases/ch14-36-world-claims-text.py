# 14장 본문이 출력 블록 없이 말한 자료의 글자·날짜 주장을 자료에서 직접 만들어 고정하는 주장 케이스입니다.
# 날짜·이름은 큰따옴표로 감싸 냅니다. 받치는 자리: problem 1 지문 「11월 1~4일의 줄이 있습니다」(현장 수첩의 첫 날짜·마지막 날짜),
# 다음 장 예고 「바람재 같은 유인 관측소」·「솔등 같은 자동 관측소」(관측소 종류), 14.3절 practice 지문의 이름 「솔등」.
import json
import unicodedata
from pathlib import Path

notebook = Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()
dates = sorted({line.split("|")[1].strip() for line in notebook})
stations = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]

rows = [
    ("현장 수첩의 첫 날짜", '"' + dates[0] + '"'),
    ("현장 수첩의 마지막 날짜", '"' + dates[-1] + '"'),
    ("BJ 관측소 종류", '"' + stations["BJ"]["kind"] + '"'),
    ("SD 관측소 종류", '"' + stations["SD"]["kind"] + '"'),
    ("SD 관측소 이름", '"' + stations["SD"]["name"] + '"'),
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
