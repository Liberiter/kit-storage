# exercise 1 지문(코드) · exercise 1 해설(출력) — work/ex1.py 의 화면입니다.
lines = [
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
    "SD|2025-11-07|1.2|10.0|0.0|구름많음",
    "SD|2025-11-08|-1.4|5.9|0.0|흐림",
]
rows = [line.split("|") for line in lines]
print([cells[1][-2:] for cells in rows if float(cells[4]) > 0])
print({cells[1][-2:]: float(cells[2]) for cells in rows})
print(sorted({cells[5] for cells in rows}))
