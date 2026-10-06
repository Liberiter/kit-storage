# 9.1절 «따라 하기» 4단계 — sorted() 와 sort() 를 견주는 work/sort_high.py 입니다.
bj_high = [7.8, 10.9, 8.4, 9.3, 10.4, 7.6, 3.2, 7.2, 5.1, 7.8]
top = sorted(bj_high)
print("sorted() 뒤:", bj_high[:3], top[-3:])
bj_high.sort()
print("sort() 뒤:", bj_high[:3], bj_high[-3:])
