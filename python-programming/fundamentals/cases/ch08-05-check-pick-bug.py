# 8.1절 «왜 그럴까요» — 고르기 조건을 >= 0 으로 잘못 적은 work/check_pick.py 입니다.
def read_rows(records):
    rows = []
    for line in records:
        rows.append(line.split("|"))
    return rows


def pick_rainy(rows):
    rainy = []
    for cells in rows:
        if float(cells[4]) >= 0:
            rainy.append(cells)
    return rainy


sample = [
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
]
sample_rows = read_rows(sample)
print(len(sample_rows), sample_rows[1])
picked = pick_rainy(sample_rows)
print(len(picked))
for cells in picked:
    print(cells[1], cells[4])
