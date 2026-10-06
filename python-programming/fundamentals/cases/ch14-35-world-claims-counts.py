# 14장 본문이 출력 블록 없이 말한 자료의 수치 주장을 자료에서 직접 세어 고정하는 주장 케이스입니다(값은 모두 정수).
# 받치는 자리: 14.1절 «예측해 보기» 「바람재 11월 4일의 줄은 한 줄」, 14.1절 «개념» 「실습 폴더의 자료 파일도 모두 UTF-8로
# 적혀 있습니다」·「실습 폴더의 자료 파일은 마지막 줄까지 줄바꿈으로 끝납니다」, problem 1 지문 「11월 1~4일의 줄」(날짜 가짓수),
# 복습 exercise 3 힌트 「관측소마다 기록이 30일」, 다음 장 예고 「유인 관측소에는 관측자가」·「자동 관측소에는 전송 주기가」.
import json
import unicodedata
from pathlib import Path

data_files = sorted(Path("data").iterdir())
raw = {path: path.read_bytes() for path in data_files}


def decodes(blob):
    try:
        blob.decode("utf-8")
    except UnicodeDecodeError:
        return False
    return True


lines = Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
notebook = Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()
notebook_dates = {line.split("|")[1].strip() for line in notebook}
readings = json.loads(Path("data/readings.json").read_text(encoding="utf-8"))
stations = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["stations"]
staffed = [code for code, info in stations.items() if info["kind"] == "유인"]
automatic = [code for code, info in stations.items() if info["kind"] == "자동"]

rows = [
    ("자료 파일 수 (data/)", len(data_files)),
    ("UTF-8로 읽히지 않는 자료 파일 수", sum(1 for blob in raw.values() if not decodes(blob))),
    ("줄바꿈으로 끝나지 않는 자료 파일 수", sum(1 for blob in raw.values() if not blob.endswith(b"\n"))),
    ("기록 파일의 바람재 11월 4일 줄 수", sum(1 for line in lines if line.startswith("BJ|2025-11-04|"))),
    ("현장 수첩에 적힌 날짜 가짓수", len(notebook_dates)),
    ("readings.json 기록이 30건이 아닌 관측소 수", sum(1 for v in readings["stations"].values() if len(v) != 30)),
    ("유인 관측소 가운데 observer 가 없는 수", sum(1 for code in staffed if "observer" not in stations[code])),
    ("자동 관측소 가운데 interval_min 이 없는 수", sum(1 for code in automatic if "interval_min" not in stations[code])),
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
