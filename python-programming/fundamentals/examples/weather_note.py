"""저녁 알림 문구를 만드는 모듈입니다. notice 모듈을 함께 씁니다."""

import notice


def evening_line():
    """저녁 알림 한 줄을 돌려줍니다."""
    return notice.announce("내일 아침 서리가 내리겠습니다")
