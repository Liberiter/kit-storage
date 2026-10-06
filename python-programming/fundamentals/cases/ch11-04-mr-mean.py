# 11.1절 «따라 하기» 3단계(«예측해 보기»의 셋째 파일) — 수첩에 비 온 날이 없는 물레의 평균에서 멈추는 work/mr_mean.py 의 화면입니다
# (ZeroDivisionError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/mr_mean.py"
SOURCE = """mr = [0.0, 0.0, 0.0, 0.0]
rainy = [amount for amount in mr if amount > 0]
print("비 온 날:", len(rainy))
print("평균:", sum(rainy) / len(rainy))
print("끝")
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
