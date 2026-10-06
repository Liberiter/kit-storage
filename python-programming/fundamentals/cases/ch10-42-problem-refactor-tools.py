# problem 2 해설 — 모범답안 work/ranges.py 에 포매터 검사·린터를 돌린 화면입니다.
# 임시 폴더의 work/ 에 같은 내용을 써서 부릅니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
NAME = 'work/ranges.py'
SOURCE = """def daily_ranges(lines, code):
    rows = [line.split("|") for line in lines]
    return [
        round(float(cells[3]) - float(cells[2]), 1)
        for cells in rows
        if cells[0] == code
    ]


records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "NM|2025-11-01|2.6|7.6|0.0|구름많음",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "NM|2025-11-02|1.6|10.8|0.0|흐림",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "NM|2025-11-03|2.4|7.4|0.0|흐림",
]
for code in ["BJ", "NM"]:
    ranges = daily_ranges(records, code)
    print(code, ranges, max(ranges))
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
