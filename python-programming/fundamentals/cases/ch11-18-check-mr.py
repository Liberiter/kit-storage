# 11.3절 «따라 하기» 2단계 — 물레의 강수량으로 read_amounts 와 비 온 날 리스트를 확인하는 work/check_mr.py 입니다.
def read_amounts(texts):
    amounts = []
    missing = 0
    for text in texts:
        try:
            amounts.append(float(text))
        except ValueError:
            missing = missing + 1
    return amounts, missing


mr_texts = ["0.0", "0.0", "0.0", "0.0"]
amounts, missing = read_amounts(mr_texts)
print(amounts, missing)
print([amount for amount in amounts if amount > 0])
