# 11.1절 «흔한 실수» — 「결측」을 0.0으로 바꿔 넣어 오류 없이 틀린 평균을 내는 work/sd_zero.py 입니다.
sd_texts = ["0.0", "결측", "8.8", "3.9"]
amounts = []
for text in sd_texts:
    if text == "결측":
        amounts.append(0.0)
    else:
        amounts.append(float(text))
print("솔등 11월 1~4일 하루 평균:", round(sum(amounts) / len(amounts), 1))
