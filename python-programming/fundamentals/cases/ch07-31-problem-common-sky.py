# problem 2 해설의 모범답안 work/common_sky.py 입니다 (지문의 요구 화면과 같은 출력).
def count_days(sky, target="눈"):
    count = 0
    for letter in sky:
        if letter == target:
            count = count + 1
    return count


def most_common(sky):
    counts = {}
    for letter in sky:
        if letter in counts:
            counts[letter] = counts[letter] + 1
        else:
            counts[letter] = 1
    best = sky[0]
    for letter in counts:
        if counts[letter] > counts[best]:
            best = letter
    return best


skies = {
    "바람재": "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구",
    "솔등": "흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑",
    "너미": "구흐흐비비구흐흐구맑구구눈눈맑흐흐흐흐맑구비비흐구맑맑눈맑맑",
    "하곡": "흐구구비비맑흐구흐맑맑흐비비구구구흐구흐구눈눈맑흐흐구비흐흐",
    "물레": "흐맑흐비비흐흐맑맑흐맑맑비눈흐구구흐흐구구눈눈흐맑흐흐눈흐흐",
    "갈숲": "흐구맑비비구맑구맑맑구구눈비흐맑흐맑흐맑맑눈눈흐흐흐흐눈맑흐",
}
for name in skies:
    top = most_common(skies[name])
    print(f"{name}: {top} {count_days(skies[name], top)}일")
