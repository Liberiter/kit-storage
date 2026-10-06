# exercise 4 지문(코드)과 해설(출력) work/ex4.py 입니다 — 함수 안에서 난 예외를 부른 쪽의 try 가 잡습니다.
def rainy_mean(amounts):
    rainy = [amount for amount in amounts if amount > 0]
    return sum(rainy) / len(rainy)


stations = [
    ("BJ", [0.0, 0.0, 9.4, 3.5]),
    ("MR", [0.0, 0.0, 0.0, 0.0]),
    ("HG", [0.0, 0.0, 7.2, 2.8]),
]
for code, amounts in stations:
    try:
        print(code, rainy_mean(amounts))
    except ZeroDivisionError:
        print(code, "비 온 날 없음")
print("끝")
