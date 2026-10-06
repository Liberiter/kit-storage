# 13.2절 «따라 하기» 2단계 — 날짜 문자열을 날짜 값으로 바꾸고 요일 번호를 내는 work/which_day.py 의 화면입니다.
# 13.2절 «예측해 보기»의 블록도 같은 파일입니다.
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/which_day.py": """import datetime

day = datetime.date.fromisoformat("2025-11-04")
print(day)
print(type(day))
print(day.weekday())
""",
}
# 화면에 나오는 차례대로 실행하는 파일입니다. 실습 폴더에서 uv run python 으로 실행할 때와
# 같은 파이썬(이 케이스를 실행하는 파이썬)으로, 임시 폴더를 실행 자리로 삼아 부릅니다.
COMMANDS = [["work/which_day.py"]]

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
