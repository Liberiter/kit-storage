# 11.1절 «왜 그럴까요» — 마지막 줄의 닫는 괄호를 뺀 work/to_number_broken.py 의 화면입니다 (SyntaxError, 한 줄도 실행되지 않음).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/to_number_broken.py"
SOURCE = """texts = ["9.4", "8.8", "결측", "7.2"]
for text in texts:
    print(float(text))
print("끝"
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
