# problem 1 해설의 모범답안 work/station_card.py 입니다 (지문의 요구 화면과 같은 출력).
def average(values):
    return sum(values) / len(values)


def largest_range(lows, highs):
    most = 0
    for index in range(len(lows)):
        gap = highs[index] - lows[index]
        if gap > most:
            most = gap
    return most


def wet_count(amounts, limit=0.1):
    count = 0
    for amount in amounts:
        if amount >= limit:
            count = count + 1
    return count


def print_card(name, lows, highs, rains):
    print(f"[{name}] 11월 1~10일")
    print(f"  평균 최고기온: {average(highs):.1f}도")
    print(f"  가장 큰 일교차: {largest_range(lows, highs):.1f}도")
    print(f"  비 온 날: {wet_count(rains)}일")


bj_low = [-1.5, 1.6, 0.3, 1.3, 1.6, -1.7, -1.8, -1.4, -2.8, -1.3]
bj_high = [7.8, 10.9, 8.4, 9.3, 10.4, 7.6, 3.2, 7.2, 5.1, 7.8]
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
nm_low = [2.6, 1.6, 2.4, 3.7, 3.3, -0.5, 2.6, 2.5, 1.0, -0.5]
nm_high = [7.6, 10.8, 7.4, 9.8, 12.0, 7.1, 9.8, 10.7, 8.3, 7.5]
nm_rain = [0.0, 0.0, 0.0, 8.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
print_card("바람재", bj_low, bj_high, bj_rain)
print_card("너미", nm_low, nm_high, nm_rain)
