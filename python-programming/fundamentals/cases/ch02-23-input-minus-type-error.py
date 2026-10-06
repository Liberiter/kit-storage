# 2.3절 «왜 그럴까요»의 둘째 실험 — 바꾸지 않은 입력으로 뺄셈을 한 work/input_minus.py
# 의 화면입니다 (TypeError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다. 입력 줄은 같은 이름의 .stdin 에 있고, 러너가 흘려 넣는
# 표준 입력을 그대로 넘깁니다. 파이프로 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은
# 이 케이스의 출력에 없습니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/input_minus.py"
SOURCE = """elevation = input("고도(m): ")
print(612 - elevation)
"""

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    with open(os.path.join(tmp, NAME), "w", encoding="utf-8") as f:
        f.write(SOURCE)
    done = subprocess.run(
        [sys.executable, NAME], cwd=tmp, stdin=sys.stdin, capture_output=True, text=True
    )
    screen = done.stdout + done.stderr
    for root in (os.path.realpath(tmp), tmp):
        screen = screen.replace(root + os.sep, "")
print(screen, end="")
sys.exit(done.returncode)
