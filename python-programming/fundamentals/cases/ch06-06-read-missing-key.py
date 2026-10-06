# 6.1절 «왜 그럴까요» — 없는 키를 먼저 꺼내 멈추는 work/no_check.py 의 화면입니다 (KeyError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/no_check.py"
SOURCE = """lines = ["BJ|2025-11-04|1.3|9.3|13.6|비", "GS|2025-11-04|0.9|8.7|2.0|비"]
totals = {}
for line in lines:
    parts = line.split("|")
    code = parts[0]
    totals[code] = totals[code] + float(parts[4])
print(totals)
"""

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    with open(os.path.join(tmp, NAME), "w", encoding="utf-8") as f:
        f.write(SOURCE)
    done = subprocess.run(
        [sys.executable, NAME], cwd=tmp, capture_output=True, text=True
    )
    screen = done.stdout + done.stderr
    for root in (os.path.realpath(tmp), tmp):
        screen = screen.replace(root + os.sep, "")
print(screen, end="")
sys.exit(done.returncode)
