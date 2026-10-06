# 11.3절 «문제 상황» — 함수를 세 겹 거쳐 물레에서 멈추는 work/station_report.py 의 화면입니다 (ZeroDivisionError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/station_report.py"
SOURCE = """notes = {
    "BJ": ["0.0", "0.0", "9.4", "3.5"],
    "SD": ["0.0", "결측", "8.8", "3.9"],
    "NM": ["0.0", "0.0", "결측", "3.1"],
    "HG": ["0.0", "0.0", "7.2", "2.8"],
    "MR": ["0.0", "0.0", "0.0", "0.0"],
    "GS": ["0.0", "결측", "8.1", "3.3"],
}


def read_amounts(texts):
    amounts = []
    missing = 0
    for text in texts:
        try:
            amounts.append(float(text))
        except ValueError:
            missing = missing + 1
    return amounts, missing


def rainy_mean(amounts):
    rainy = [amount for amount in amounts if amount > 0]
    return sum(rainy) / len(rainy)


def report(notes):
    for code in notes:
        amounts, missing = read_amounts(notes[code])
        mean = rainy_mean(amounts)
        print(f"{code}: 결측 {missing}일, 비 온 날 평균 {mean:.2f}mm")


report(notes)
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
