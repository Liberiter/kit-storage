# 13.1절 practice 1 풀이 — 솔등 11월 1~10일의 중앙값·평균을 내는 work/stats_sd.py 의 화면입니다.
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

FILES = {
    "work/stats_sd.py": """import statistics

sd_low = [-1.0, -1.3, 2.3, 0.9, 1.7, -0.0, 1.2, -1.4, 1.3, -2.7]
sd_high = [4.8, 4.7, 8.9, 6.0, 7.8, 8.6, 10.0, 5.9, 7.3, 5.4]
print("최저기온 중앙값:", statistics.median(sd_low))
print("최고기온 평균:", round(statistics.mean(sd_high), 2))
""",
}
# 화면에 나오는 차례대로 실행하는 파일입니다. 실습 폴더에서 uv run python 으로 실행할 때와
# 같은 파이썬(이 케이스를 실행하는 파이썬)으로, 임시 폴더를 실행 자리로 삼아 부릅니다.
COMMANDS = [["work/stats_sd.py"]]

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
