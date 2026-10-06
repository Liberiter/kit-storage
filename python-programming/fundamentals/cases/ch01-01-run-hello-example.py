# 1.1절 «따라 하기» 1단계 — uv run python examples/hello_baramjae.py 의 화면입니다.
# 실습 폴더에 들어 있는 예제 파일을 그대로 실행해 받습니다.
import subprocess
import sys

done = subprocess.run(
    [sys.executable, "examples/hello_baramjae.py"],
    capture_output=True,
    text=True,
)
print(done.stdout, end="")
print(done.stderr, end="")
sys.exit(done.returncode)
