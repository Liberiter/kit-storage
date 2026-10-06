# 8.1절 «문제 상황» — uv run python examples/report.py 의 화면입니다.
# 실습 폴더에 들어 있는 예제 파일을 그대로 실행해 받습니다.
import subprocess
import sys

done = subprocess.run(
    [sys.executable, "examples/report.py"],
    capture_output=True,
    text=True,
)
print(done.stdout, end="")
print(done.stderr, end="")
sys.exit(done.returncode)
