"""notice 모듈을 두 곳에서 불러들여, 맨 위 문장이 언제 실행되는지 봅니다."""

import notice
import weather_note

print(notice.announce("오늘 낮 기온이 크게 떨어집니다"))
print(weather_note.evening_line())
