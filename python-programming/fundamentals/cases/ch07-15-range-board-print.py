# 7.3절 «문제 상황» — 화면에 내는 함수와 밖에서 다시 적은 계산의 work/range_board.py 입니다.
def show_range(name, low, high):
    print(f"{name} 일교차: {high - low:.1f}도")


names = ["바람재", "솔등", "너미", "하곡", "물레", "갈숲"]
lows = [-1.5, -1.0, 2.6, 1.0, 2.1, 0.3]
highs = [7.8, 4.8, 7.6, 8.2, 11.4, 5.9]
most = 0
for index in range(len(names)):
    show_range(names[index], lows[index], highs[index])
    if highs[index] - lows[index] > most:
        most = highs[index] - lows[index]
print(f"가장 큰 일교차: {most:.1f}도")
