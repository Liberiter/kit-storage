# 13.2절 «따라 하기» 3단계 — 바람재의 비·눈 온 날을 요일과 함께 내는 work/rainy_weekdays.py 의 화면입니다.
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/rainy_weekdays.py": """import datetime

# 참고: datetime — Basic date and time types, date.fromisoformat()·date.weekday()
# https://docs.python.org/3.14/library/datetime.html#datetime.date.fromisoformat
day_names = ["월", "화", "수", "목", "금", "토", "일"]
rainy_dates = ["2025-11-04", "2025-11-05", "2025-11-08", "2025-11-09", "2025-11-10"]
for text in rainy_dates:
    day = datetime.date.fromisoformat(text)
    print(text, day_names[day.weekday()] + "요일")
""",
}
# 화면에 나오는 차례대로 실행하는 파일입니다. 실습 폴더에서 uv run python 으로 실행할 때와
# 같은 파이썬(이 케이스를 실행하는 파이썬)으로, 임시 폴더를 실행 자리로 삼아 부릅니다.
COMMANDS = [["work/rainy_weekdays.py"]]

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
