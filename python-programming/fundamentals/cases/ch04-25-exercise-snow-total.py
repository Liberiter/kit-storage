# «연습하기» exercise 2 해설 — 모범답안 work/ex2.py 입니다(지문이 요구 화면을 먼저 싣는다).
snow_stations = "000000011100440000000550000500"
total = 0
most = 0
most_day = 0
day = 0
for count_text in snow_stations:
    day = day + 1
    count = int(count_text)
    total = total + count
    if count > most:
        most = count
        most_day = day
print(f"11월에 눈이 온 기록: 모두 {total}건")
print(f"눈 온 관측소가 가장 많았던 날: 11월 {most_day}일 ({most}곳)")
