# 13.1절 «따라 하기» 1단계 — statistics 모듈로 중앙값과 평균을 내는 work/stats_low.py 의 화면입니다.
# 13.1절 «예측해 보기»의 블록도 같은 파일입니다.
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/stats_low.py": """import statistics

bj_low = [-1.5, 1.6, 0.3, 1.3, 1.6, -1.7, -1.8, -1.4, -2.8, -1.3]
print("중앙값:", statistics.median(bj_low))
print("평균:", round(statistics.mean(bj_low), 2))
""",
}
# 화면에 나오는 차례대로 실행하는 파일입니다. 실습 폴더에서 uv run python 으로 실행할 때와
# 같은 파이썬(이 케이스를 실행하는 파이썬)으로, 임시 폴더를 실행 자리로 삼아 부릅니다.
COMMANDS = [["work/stats_low.py"]]

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
