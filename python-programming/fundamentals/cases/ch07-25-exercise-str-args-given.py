# exercise 3 지문(코드)과 해설 (a) 「고치기 전의 화면」 — work/ex3.py 입니다 (TypeError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/ex3.py"
SOURCE = """def daily_range(low, high):
    return high - low


line = "BJ|2025-11-01|-1.5|7.8|0.0|흐림"
parts = line.split("|")
gap = daily_range(parts[2], parts[3])
print(f"{parts[0]} {parts[1]} 일교차: {gap:.1f}도")
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
