# 5.1절 «왜 그럴까요» — 빈 리스트에 max() 를 부른 work/dry_week.py 의 화면입니다 (ValueError).
# 여러분이 work/ 에 만드는 파일과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

NAME = "work/dry_week.py"
SOURCE = """dry_week = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
wet = []
for amount in dry_week:
    if amount > 0:
        wet.append(amount)
print(f"비나 눈이 온 날: {len(wet)}일, 합계: {sum(wet)}mm")
print(f"가장 많이 온 양: {max(wet)}mm")
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
