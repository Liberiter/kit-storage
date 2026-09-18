# 러너의 기본 유형입니다 — 자료 파일을 읽어 화면에 결과를 냅니다.
# 이 케이스가 받치는 것: 실습 자료의 관측 기록이 처음 상태 그대로인지.
from pathlib import Path

lines = Path("data/readings.txt").read_text(encoding="utf-8").splitlines()
rows = [line.split("|") for line in lines]

codes = sorted({row[0] for row in rows})
dates = sorted({row[1] for row in rows})
rain_total = 0.0
for row in rows:
    rain_total = rain_total + float(row[4])

print("기록 줄 수:", len(rows))
print("관측소:", " ".join(codes))
print("날짜:", dates[0], "~", dates[-1])
print("강수량 합계:", round(rain_total, 1))
