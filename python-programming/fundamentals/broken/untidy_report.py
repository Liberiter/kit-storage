"""서식과 규칙을 일부러 어겨 둔 파일입니다."""
def summary(station,rains) :
    added=0.0
    days = 0
    unused = "여기 있지만 아무도 쓰지 않습니다"
    for value in rains :
        added=added+value
        days = days+1
    mean = added/days
    print( "관측소", station, "합계", round(added,1), "평균", round(mean,2) )
    print("이 줄은 여든여덟 칸을 넘기도록 일부러 길게 적어 둔 안내 문장입니다. 포매터가 문자열을 잘라 주지는 않습니다.")
summary("바람재",[0.1,0.2,0.3])
