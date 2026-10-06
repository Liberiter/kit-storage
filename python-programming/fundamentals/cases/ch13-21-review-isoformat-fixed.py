# 복습 exercise 3 해설 — 날짜 칸의 빈칸을 걷어 고친 work/review3.py 의 화면입니다.
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/review3.py": """import datetime
import statistics

lines = [
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
    "PT | 2025-11-04 | 결측",
]
day = datetime.date.fromisoformat(lines[0].split("|")[1].strip())
amounts = []
for line in lines:
    try:
        amounts.append(float(line.split("|")[2]))
    except ValueError:
        print("수로 바꿀 수 없는 줄:", line)
print(day, "평균 강수량:", round(statistics.mean(amounts), 2))
""",
}
# 화면에 나오는 차례대로 실행하는 파일입니다. 실습 폴더에서 uv run python 으로 실행할 때와
# 같은 파이썬(이 케이스를 실행하는 파이썬)으로, 임시 폴더를 실행 자리로 삼아 부릅니다.
COMMANDS = [["work/review3.py"]]

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    for name, source in FILES.items():
        with open(os.path.join(tmp, name), "w", encoding="utf-8") as f:
            f.write(source)
    code = 0
    for args in COMMANDS:
        command = [sys.executable, *args]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        screen = done.stdout + done.stderr
        for root in (os.path.realpath(tmp), tmp):
            screen = screen.replace(root + os.sep, "")
        print(screen, end="")
        code = done.returncode
sys.exit(code)
