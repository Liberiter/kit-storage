# 11.3절 «흔한 실수» — 다듬지 않은 코드를 넘겨 station_name 안에서 멈추는 work/name_report.py 의 화면입니다 (KeyError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/name_report.py"
SOURCE = """names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}


def station_name(code):
    return names[code]


lines = [
    " bj | 2025-11-01 | 0.0",
    "Sd|2025-11-01|0.0",
    "nm | 2025-11-01|0.0",
    " HG|2025-11-01 | 0.0",
    "mr|2025-11-01|0.0",
    "gs | 2025-11-01 | 0.0",
]
for line in lines:
    code = line.split("|")[0]
    print(station_name(code))
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
