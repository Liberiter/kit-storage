# 12.2절 «흔한 실수» 첫 화면 — 함수 정의까지 메인 가드 안에 넣은 work/sky_steps.py 를 임포트한 work/snow_days.py 의 화면입니다 (AttributeError).
# 여러분이 work/ 에 만드는 파일들과 같은 내용을 임시 폴더의 work/ 에 써서 실행하고,
# 화면에 찍힌 전체 경로에서 그 임시 폴더 부분을 떼어 냅니다. 본문은 실습 폴더
# 아래 부분(work/...)만 싣기 때문입니다.
import os
import subprocess
import sys
import tempfile

KIT = os.getcwd()
RUFF = os.path.join(sys.prefix, "bin", "ruff")
FILES = {
    "work/sky_steps.py": """if __name__ == "__main__":

    def count_snow(skies):
        return len([sky for sky in skies if sky == "눈"])

    print("[확인] 눈 온 날:", count_snow(["눈", "비", "눈"]))
""",
    "work/snow_days.py": """import sky_steps

bj_sky = ["흐림", "맑음", "흐림", "비", "비", "구름많음", "맑음", "눈", "눈", "눈"]
print("바람재 11월 1~10일 눈 온 날:", sky_steps.count_snow(bj_sky))
""",
}
# 화면에 나오는 차례대로 부르는 명령입니다. "python" 은 work/ 의 그 파일을 실행하는
# 것이고, "ruff" 는 실습 폴더의 설정 파일을 주어 그 하위 명령을 부르는 것입니다.
COMMANDS = [["python", "work/snow_days.py"]]

with tempfile.TemporaryDirectory() as tmp:
    os.makedirs(os.path.join(tmp, "work"))
    for name, source in FILES.items():
        with open(os.path.join(tmp, name), "w", encoding="utf-8") as f:
            f.write(source)
    code = 0
    for args in COMMANDS:
        if args[0] == "python":
            command = [sys.executable, *args[1:]]
        else:
            config = ["--config", os.path.join(KIT, "pyproject.toml"), "--no-cache"]
            command = [RUFF, args[1], *config, *args[2:]]
        done = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        screen = done.stdout + done.stderr
        for root in (os.path.realpath(tmp), tmp):
            screen = screen.replace(root + os.sep, "")
        print(screen, end="")
        code = done.returncode
sys.exit(code)
