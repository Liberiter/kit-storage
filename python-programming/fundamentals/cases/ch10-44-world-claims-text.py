# 10장 본문이 실습 폴더의 설정에서 인용한 글자 주장을 설정 파일에서 직접 읽어 고정하는 주장 케이스입니다.
# 받치는 자리: 10.3절 «개념»의 「이 실습 폴더는 린터에게 E·F·W 세 묶음의 규칙을 쓰라고 정해 두었습니다」.
# 값은 설정 파일에 적힌 모양 그대로(큰따옴표로 감싼 리스트) 냅니다.
import tomllib
import unicodedata

with open("pyproject.toml", "rb") as f:
    ruff = tomllib.load(f)["tool"]["ruff"]

select = ruff["lint"]["select"]
rows = [
    ("pyproject.toml [tool.ruff.lint] select", "[" + ", ".join('"' + s + '"' for s in select) + "]"),
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
