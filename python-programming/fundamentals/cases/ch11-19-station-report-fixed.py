# 11.3절 «따라 하기» 3단계 — rainy_mean 이 ZeroDivisionError 를 잡아 None 을 돌려주게 고친 work/station_report.py
# 입니다.
notes = {
    "BJ": ["0.0", "0.0", "9.4", "3.5"],
    "SD": ["0.0", "결측", "8.8", "3.9"],
    "NM": ["0.0", "0.0", "결측", "3.1"],
    "HG": ["0.0", "0.0", "7.2", "2.8"],
    "MR": ["0.0", "0.0", "0.0", "0.0"],
    "GS": ["0.0", "결측", "8.1", "3.3"],
}


def read_amounts(texts):
    amounts = []
    missing = 0
    for text in texts:
        try:
            amounts.append(float(text))
        except ValueError:
            missing = missing + 1
    return amounts, missing


def rainy_mean(amounts):
    rainy = [amount for amount in amounts if amount > 0]
    try:
        return sum(rainy) / len(rainy)
    except ZeroDivisionError:
        return None


def report(notes):
    for code in notes:
        amounts, missing = read_amounts(notes[code])
        mean = rainy_mean(amounts)
        if mean is None:
            print(f"{code}: 결측 {missing}일, 비 온 날 없음")
        else:
            print(f"{code}: 결측 {missing}일, 비 온 날 평균 {mean:.2f}mm")


report(notes)
