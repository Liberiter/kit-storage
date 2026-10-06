# 8장 본문 코드가 자료에서 옮겨 적은 값(관측망 나무의 짜임, 기록 파일의 줄)을 자료에서 직접 만들어 고정하는
# 주장 케이스입니다. 리스트는 본문 코드처럼 대괄호로, 줄과 이름은 본문 코드의 문자열 리터럴처럼 큰따옴표로
# 감싸 냅니다.
# 받치는 자리: 8.2절 «문제 상황»의 나무 그림과 tree, 8.2절 «예측해 보기»·«따라 하기»·«왜 그럴까요»의 mountain,
# 8.2절 «개념»의 호출 그림(윗재·너미골의 관측소 수), 8.2절 이후 모든 tree 블록(«흔한 실수», practice 1,
# exercise 1·2·4, 복습 exercise 1·2, problem 2), 8.1절 «따라 하기»·«왜 그럴까요»·practice 1의 바람재 1~10일 줄,
# 8.1절 «따라 하기» 3단계의 솔등 1~10일 줄(-0.0 포함), exercise 3의 너미 1~10일 줄, problem 1의 바람재 1~14일 줄.
import json
import unicodedata
from pathlib import Path

lines = [
    line
    for line in Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
    if line.strip()
]
rows_raw = [line.split("|") for line in lines]
tree = json.loads(Path("data/stations.json").read_text(encoding="utf-8"))["tree"]


def quoted(text):
    # 본문 코드의 문자열 리터럴과 같은 모양(큰따옴표로 감싼 글자)으로 냅니다.
    return '"' + text + '"'


def listed(items):
    return "[" + ", ".join(quoted(item) for item in items) + "]"


rows = [("나무 맨 위 마디 이름", quoted(tree["name"]))]


def walk(node):
    name = node["name"]
    rows.append((f"{name}의 children 이름", listed(c["name"] for c in node["children"])))
    rows.append((f"{name}의 stations", listed(node["stations"])))
    for child in node["children"]:
        walk(child)


walk(tree)


def picked(code, first, last):
    return sorted(
        r for r in rows_raw if r[0] == code and first <= int(r[1][-2:]) <= last
    )


for code, name, last in [("BJ", "바람재", 14), ("SD", "솔등", 10), ("NM", "너미", 10)]:
    for r in picked(code, 1, last):
        rows.append((f"기록 파일 {name} 11월 {int(r[1][-2:])}일 줄", quoted("|".join(r))))


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
