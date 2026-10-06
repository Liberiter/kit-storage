# 10.3절 «왜 그럴까요» — 10.1절 3단계의 work/rain_by_date.py 를 줄 폭 88(설정 그대로)과 79로 검사하고, 79로 포매터가 바꿀 자리를 본 화면입니다.
# 임시 폴더의 work/ 에 같은 내용을 써서 도구를 부릅니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
NAME = 'work/rain_by_date.py'
SOURCE = """records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "BJ|2025-11-06|-1.7|7.6|0.0|구름많음",
    "BJ|2025-11-07|-1.8|3.2|0.0|맑음",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    "BJ|2025-11-09|-2.8|5.1|0.2|눈",
    "BJ|2025-11-10|-1.3|7.8|0.3|눈",
]
rows = [line.split("|") for line in records]
rain_by_date = {cells[1]: float(cells[4]) for cells in rows if float(cells[4]) > 0}
print(rain_by_date)
print(rain_by_date["2025-11-04"], len(rain_by_date))
"""
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 그 파일을 실행하는 것이고,
# 나머지는 ruff 의 하위 명령입니다. 실습 폴더의 설정 파일을 그대로 씁니다.
COMMANDS = [['check'], ['check', '--line-length', '79'], ['format', '--diff', '--line-length', '79']]

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    with open(os.path.join(tmp, NAME), "w", encoding="utf-8") as f:
        f.write(SOURCE)
    code = 0
    for args in COMMANDS:
        if args[0] == "python":
            command = [sys.executable, NAME]
        else:
            config = ["--config", os.path.join(KIT, "pyproject.toml"), "--no-cache"]
            command = [RUFF, args[0], *config, *args[1:], NAME]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        print(done.stdout, end="")
        print(done.stderr, end="")
        code = done.returncode
sys.exit(code)
