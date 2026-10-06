# 7.2절 «흔한 실수» — 인수의 차례를 바꿔 적은 줄과 키워드 인수로 고친 줄의 work/swapped.py 입니다.
def show_range(name, low, high):
    print(f"{name} 일교차: {high - low:.1f}도")


show_range("바람재", 7.8, -1.5)
show_range("바람재", high=7.8, low=-1.5)
