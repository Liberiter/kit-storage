# 8장 본문이 자료에 대해 말하는 정수 주장 가운데 출력 블록에 찍히지 않는 것을 자료에서 직접 세어 고정하는
# 주장 케이스입니다.
# 받치는 자리: 8.2절 «문제 상황»의 「관측망 아래에 권역 둘이, 권역마다 그 아래에 지역 둘이」, 8.2절 «따라 하기»
# 2단계의 「관측망 → 권역 → 지역으로 세 단」, 복습 exercise 2의 「현장 수첩의 11월 3일 일곱 줄」, exercise 4
# 해설의 「PT 는 어느 마디의 "stations" 에도 없으므로」, 복습 exercise 1 해설의 「나무에 달린 코드는 모두 totals
# 의 키에 있으므로」(관측소 목록에 없는 나무의 코드 0개), 8.1절 «문제 상황»의 examples/report.py 기록 열 줄이
# 기록 파일의 바람재 11월 1~10일 줄 그대로라는 것(다른 줄 0개 — 8.1절 «따라 하기»가 같은 줄을 옮겨 적는다).
import ast
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
data = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))
tree = data["tree"]
log = [
    line
    for line in Path("data/field_log.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]


def depth(node):
    return 1 + max([depth(c) for c in node["children"]], default=0)


def codes(node):
    found = list(node["stations"])
    for child in node["children"]:
        found.extend(codes(child))
    return found


report = ast.parse(Path("examples/report.py").read_text(encoding="utf-8"))
records = []
for stmt in report.body:
    if isinstance(stmt, ast.Assign) and stmt.targets[0].id == "records":
        records = [elt.value for elt in stmt.value.elts]
bj_first_ten = [
    line for line in lines if line.startswith("BJ|") and int(line[11:13]) <= 10
]

rows = [
    ("맨 위 마디의 하위 마디 수", len(tree["children"])),
    ("산마루 권역의 하위 마디 수", len(tree["children"][0]["children"])),
    ("들녘 권역의 하위 마디 수", len(tree["children"][1]["children"])),
    ("나무의 단 수", depth(tree)),
    ("현장 수첩 11월 3일 줄 수", sum(1 for x in log if x.split("|")[1].strip() == "2025-11-03")),
    ("나무에 달린 PT 수", sum(1 for c in codes(tree) if c == "PT")),
    ("관측소 목록에 없는 나무의 코드 수", sum(1 for c in codes(tree) if c not in data["stations"])),
    ("report.py 기록 줄 수", len(records)),
    ("report.py 기록 줄 가운데 기록 파일과 다른 줄 수", sum(1 for a, b in zip(records, bj_first_ten) if a != b)),
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
