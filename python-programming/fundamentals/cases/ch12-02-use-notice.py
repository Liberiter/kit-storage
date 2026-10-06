# 12.1절 «따라 하기» 3단계 — uv run python examples/use_notice.py 의 화면입니다.
# 실습 폴더에 들어 있는 예제 파일을 그대로 실행해 받습니다. -B 는 실습 폴더에
# __pycache__ 를 남기지 않게 하는 것이고 화면에는 영향이 없습니다.
import subprocess
import sys

done = subprocess.run(
    [sys.executable, "-B", "examples/use_notice.py"],
    capture_output=True,
    text=True,
)
print(done.stdout, end="")
print(done.stderr, end="")
sys.exit(done.returncode)
