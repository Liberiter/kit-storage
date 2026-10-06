# 복습 exercise 1 해설의 모범답안 work/review1.py 입니다 (지문의 요구 화면과 같은 출력).
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
totals = {"BJ": 67.1, "SD": 59.4, "NM": 56.2, "HG": 58.5, "MR": 61.0, "GS": 48.6}
for code in totals:
    if totals[code] >= 60:
        level = "많음"
    elif totals[code] >= 50:
        level = "보통"
    else:
        level = "적음"
    print(f"{names[code]}: {totals[code]}mm — {level}")
