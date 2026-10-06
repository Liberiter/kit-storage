# problem 1 해설 — 모범답안 work/freezing.py 에 포매터 검사·린터를 돌린 화면입니다.
# 임시 폴더의 work/ 에 같은 내용을 써서 부릅니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
NAME = 'work/freezing.py'
SOURCE = """lines = [
    "BJ|2025-11-07|-1.8|3.2|0.0|맑음",
    "SD|2025-11-07|1.2|10.0|0.0|구름많음",
    "NM|2025-11-07|2.6|9.8|0.0|흐림",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    "SD|2025-11-08|-1.4|5.9|0.0|흐림",
    "NM|2025-11-08|2.5|10.7|0.0|흐림",
    "BJ|2025-11-09|-2.8|5.1|0.2|눈",
    "SD|2025-11-09|1.3|7.3|0.0|맑음",
    "NM|2025-11-09|1.0|8.3|0.0|구름많음",
    "BJ|2025-11-10|-1.3|7.8|0.3|눈",
    "SD|2025-11-10|-2.7|5.4|0.0|흐림",
    "NM|2025-11-10|-0.5|7.5|0.0|맑음",
]
rows = [line.split("|") for line in lines]
codes = ["BJ", "SD", "NM"]
freezing = {
    code: [cells[1][-2:] for cells in rows if cells[0] == code and float(cells[2]) < 0]
    for code in codes
}
for code, days in freezing.items():
    print(f"{code} 영하:", ", ".join(days))
"""
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 그 파일을 실행하는 것이고,
# 나머지는 ruff 의 하위 명령입니다. 실습 폴더의 설정 파일을 그대로 씁니다.
COMMANDS = [['format', '--check'], ['check']]

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
