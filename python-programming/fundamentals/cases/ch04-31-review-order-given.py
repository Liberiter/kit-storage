# «연습하기» 복습 exercise 2 — 지문의 고치기 전 work/review2.py 입니다(해설이 화면을 싣는다).
freezing = "210003232525443453664556566566"
all_days = 0
some_days = 0
none_days = 0
for count_text in freezing:
    count = int(count_text)
    if count >= 1:
        some_days = some_days + 1
    elif count == 6:
        all_days = all_days + 1
    else:
        none_days = none_days + 1
print(f"여섯 곳 모두 영하: {all_days}일")
print(f"일부만 영하: {some_days}일")
print(f"영하 없음: {none_days}일")
