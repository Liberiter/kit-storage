# 9.2절 «따라 하기» 2단계 첫 블록 — 튜플을 넘겨받은 함수가 원소를 바꾸려다 멈추는 work/tuple_km.py 의 화면입니다 (TypeError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/tuple_km.py"
SOURCE = """def print_km(station):
    station[2] = station[2] / 1000
    print(f"{station[1]} 고도: {station[2]}km")


bj = ("BJ", "바람재", 612)
print_km(bj)
print(f"{bj[1]} 고도: {bj[2]}m")
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
