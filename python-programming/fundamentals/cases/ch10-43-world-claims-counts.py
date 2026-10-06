# 10장 본문이 실습 폴더의 설정에서 인용한 정수 주장을 설정 파일에서 직접 읽어 고정하는 주장 케이스입니다.
# 받치는 자리: 10.2절 «개념»의 「이 실습 폴더는 88칸」과 10.3절 «개념»·«왜 그럴까요»의 「설정 파일의 line-length = 88」,
# 10.3절 «개념»의 「따옴표 모양은 이 실습 폴더가 따로 정하지 않아 Ruff 의 기본값을 따릅니다」(포매터 설정 항목 0개),
# 10.3절 «따라 하기» 1단계의 「E501의 줄은 75글자인데 너비는 120칸」(broken/untidy_report.py 11번째 줄 — 너비는 동아시아
# 넓은 글자를 두 칸으로 셉니다).
import tomllib
import unicodedata
from pathlib import Path

with open("pyproject.toml", "rb") as f:
    ruff = tomllib.load(f)["tool"]["ruff"]

line_11 = Path("broken/untidy_report.py").read_text(encoding="utf-8").split("\n")[10]
rows = [
    ("pyproject.toml [tool.ruff] line-length", ruff["line-length"]),
    ("pyproject.toml [tool.ruff.format] 설정 항목 수", len(ruff.get("format", {}))),
    ("broken/untidy_report.py 11번째 줄 글자 수", len(line_11)),
    ("broken/untidy_report.py 11번째 줄 너비", sum(2 if unicodedata.east_asian_width(ch) in "WF" else 1 for ch in line_11)),
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
