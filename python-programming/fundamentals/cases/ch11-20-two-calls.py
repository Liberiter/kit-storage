# 11.3절 «왜 그럴까요» — 같은 함수를 두 줄에서 불러 둘째 호출에서 멈추는 work/two_calls.py 의 화면입니다 (ZeroDivisionError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/two_calls.py"
SOURCE = """def rainy_mean(amounts):
    rainy = [amount for amount in amounts if amount > 0]
    return sum(rainy) / len(rainy)


bj = [0.0, 0.0, 9.4, 3.5]
mr = [0.0, 0.0, 0.0, 0.0]
print("바람재", rainy_mean(bj))
print("물레", rainy_mean(mr))
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
