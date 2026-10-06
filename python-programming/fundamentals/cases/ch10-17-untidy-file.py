# 10.3절 «문제 상황» — cat broken/untidy_report.py 의 화면(파일 내용 그대로)입니다.
from pathlib import Path

print(Path("broken/untidy_report.py").read_text(encoding="utf-8"), end="")
