# exercise 1 지문(코드)·해설(출력) work/ex1.py 입니다.
def rain_text(amount, unit="mm"):
    if unit == "cm":
        return f"{amount / 10:.2f}cm"
    else:
        return f"{amount:.1f}mm"


def show(label, text):
    print(f"{label}: {text}")


show("11월 4일", rain_text(13.6))
show("11월 5일", rain_text(unit="cm", amount=3.8))
result = show("이틀 합계", rain_text(13.6 + 3.8))
print(result)
