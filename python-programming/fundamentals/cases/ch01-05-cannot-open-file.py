# 1.1절 «흔한 실수» — 없는 파일 work/frist.py 를 실행하려 한 화면입니다.
# 빈 work/ 폴더만 있는 임시 폴더에서 실행해, 실습 폴더의 work/ 에 무엇이 있든
# 같은 화면을 받습니다. 임시 폴더의 경로는 떼어 냅니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/frist.py"

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    done = subprocess.run(
        [sys.executable, NAME], cwd=tmp, capture_output=True, text=True
    )
    screen = done.stdout + done.stderr
    for root in (os.path.realpath(tmp), tmp):
        screen = screen.replace(root + os.sep, "")
print(screen, end="")
sys.exit(done.returncode)
