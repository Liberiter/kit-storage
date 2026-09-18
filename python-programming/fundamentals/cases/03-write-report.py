# runner: reset
# 실습 자료를 바꾸는 유형입니다 — out/ 에 결과 파일을 씁니다.
# 이 케이스가 받치는 것: 결과를 쓰는 자리와 되돌리기가 함께 도는지.
from pathlib import Path

lines = Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
rows = [line.split("|") for line in lines if line.startswith("BJ|")]

made = []
for row in rows[:5]:
    made.append(f"{row[1]} 최저 {row[2]} 최고 {row[3]} 강수 {row[4]}")

out = Path("out/bj_five_days.txt")
out.write_text("\n".join(made) + "\n", encoding="utf-8")

print("쓴 파일:", out)
print(out.read_text(encoding="utf-8"), end="")
