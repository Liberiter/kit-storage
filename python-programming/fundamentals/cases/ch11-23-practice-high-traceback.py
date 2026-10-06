# 11.3절 «practice» 1 지문 — 고도 딕셔너리에 없는 코드에서 멈추는 work/high_list.py 의 화면입니다 (KeyError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/high_list.py"
SOURCE = """elevations = {"BJ": 612, "SD": 447, "NM": 158, "HG": 93, "MR": 238, "GS": 355}


def elevation_of(code):
    return elevations[code]


def high_stations(codes):
    return [code for code in codes if elevation_of(code) >= 300]


print(high_stations(["BJ", "SD", "PT", "GS"]))
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
