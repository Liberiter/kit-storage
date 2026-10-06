# 3.1절 «흔한 실수» 첫째 — True 는 문자열이 아니라는 것을 보인 work/true_text.py 입니다.
is_freezing = 0.0 <= 0
print(is_freezing)
print(type(is_freezing))
print(is_freezing == "True")
