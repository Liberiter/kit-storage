# 코스가 쓰는 검사 도구를 부르는 유형입니다.
# 이 케이스가 받치는 것: 서식·규칙을 어겨 둔 파일을 린터가 짚어 내는지.
import subprocess
import sys
from pathlib import Path

ruff = Path(sys.prefix) / "bin" / "ruff"
done = subprocess.run(
    [
        str(ruff),
        "check",
        "--no-cache",
        "--output-format",
        "concise",
        "broken/untidy_report.py",
    ],
    capture_output=True,
    text=True,
)
print(done.stdout, end="")
print(done.stderr, end="")
sys.exit(done.returncode)
