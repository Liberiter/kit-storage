"""강수량 목록을 다루는 작은 함수들입니다 — 한 곳에 결함을 심어 두었습니다."""


def total(rains):
    """강수량을 모두 더해 소수 한 자리로 돌려줍니다."""
    added = 0.0
    for value in rains:
        added = added + value
    return round(added, 1)


def rainy_days(rains):
    """0보다 큰 값이 몇 번인지 셉니다."""
    count = 0
    for value in rains:
        if value >= 0:
            count = count + 1
    return count


def heaviest(rains):
    """가장 큰 값을 돌려줍니다. 목록이 비어 있으면 0.0입니다."""
    if not rains:
        return 0.0
    top = rains[0]
    for value in rains:
        if value > top:
            top = value
    return top
