# 6.1절 «문제 상황» — 코드와 이름을 두 리스트에 적고 자리 번호로 찾는 work/two_lists.py 입니다.
codes = ["BJ", "SD", "NM", "HG", "MR", "GS"]
names = ["바람재", "솔등", "너미", "하곡", "물레", "갈숲"]
code = "SD"
for index in range(len(codes)):
    if codes[index] == code:
        print(f"{code}: {names[index]}")
