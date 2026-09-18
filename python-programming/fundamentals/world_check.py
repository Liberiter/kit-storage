"""실습 자료가 처음 상태 그대로인지 검사합니다.

`./check_env.sh` 가 이 파일을 실행합니다. 어긋난 자리가 있으면 그 자리를 한
줄씩 적고 1로 끝냅니다. 모두 맞으면 아무 말 없이 0으로 끝납니다.
"""

import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
DATA = HERE / "data"
FAILURES = []


def check(number, ok, detail):
    if not ok:
        FAILURES.append(f"{number}: {detail}")


def read_rows():
    text = (DATA / "readings.txt").read_text(encoding="utf-8")
    return [line.split("|") for line in text.splitlines()]


def main():
    wanted = ["readings.txt", "readings.json", "stations.json", "field_log.txt"]
    missing = [name for name in wanted if not (DATA / name).is_file()]
    check("W1", not missing, f"data/ 에 없는 파일: {', '.join(missing)}")
    if missing:
        report()
        return 1

    rows = read_rows()
    check("W2", len(rows) == 180, f"관측 기록이 180줄이 아닙니다 (지금 {len(rows)}줄)")
    check("W3", all(len(r) == 6 for r in rows), "칸이 6개가 아닌 줄이 있습니다")

    codes = sorted({r[0] for r in rows})
    days = sorted({r[1] for r in rows})
    check(
        "W4",
        codes == ["BJ", "GS", "HG", "MR", "NM", "SD"],
        f"관측소 목록이 다릅니다: {codes}",
    )
    check("W5", len(days) == 30, f"날짜가 30일이 아닙니다 (지금 {len(days)}일)")

    skies = sorted({r[5] for r in rows})
    check("W6", len(skies) == 5, f"하늘 상태가 5종이 아닙니다: {skies}")

    boundary = {r[2] for r in rows}
    check(
        "W7",
        {"0.0", "0.1", "-0.1"} <= boundary,
        "최저기온이 0도 언저리에서 갈리는 값(-0.1 / 0.0 / 0.1)이 모두 있지 않습니다",
    )

    # 영하에 내린 강수는 모두 「눈」으로 적혀 있어야 합니다. 조건 두 개를 조합하는
    # 예제가 이 약속 위에 서므로, 건수와 함께 한 줄도 어긋나지 않는지 봅니다.
    freezing_rain = [r for r in rows if float(r[2]) <= 0 and float(r[4]) > 0]
    check(
        "W8",
        len(freezing_rain) == 26,
        f"영하에 내린 날이 26건이 아닙니다 (지금 {len(freezing_rain)}건)",
    )
    not_snow = [f"{r[0]} {r[1]}({r[5]})" for r in freezing_rain if r[5] != "눈"]
    check(
        "W8",
        not not_snow,
        f"영하에 내렸는데 눈이 아닌 줄이 있습니다: {', '.join(not_snow[:5])}",
    )

    rains = {(r[0], r[1]): float(r[4]) for r in rows}
    a = rains.get(("BJ", "2025-11-08"))
    b = rains.get(("BJ", "2025-11-09"))
    c = rains.get(("BJ", "2025-11-10"))
    check(
        "W9",
        (a, b, c) == (0.1, 0.2, 0.3) and a + b != c,
        "더하면 딱 떨어질 것 같은데 그렇지 않은 강수량 쌍이 제자리에 없습니다",
    )

    readings_json = json.loads((DATA / "readings.json").read_text(encoding="utf-8"))
    by_station = readings_json["stations"]
    same = sum(len(v) for v in by_station.values()) == len(rows)
    sample = by_station["BJ"][7]
    check(
        "W10",
        same and sample["date"] == "2025-11-08" and sample["rain"] == 0.1,
        "JSON 파일이 텍스트 파일과 같은 사실을 담고 있지 않습니다",
    )

    stations = json.loads((DATA / "stations.json").read_text(encoding="utf-8"))
    tree = stations["tree"]
    regions = tree["children"]
    areas = [area for region in regions for area in region["children"]]
    in_tree = sorted(code for area in areas for code in area["stations"])
    check(
        "W11", len(regions) == 2 and len(areas) == 4, "관측망 나무의 마디 수가 다릅니다"
    )
    check("W12", in_tree == codes, f"나무에 적힌 관측소가 기록과 다릅니다: {in_tree}")

    kinds = sorted({s["kind"] for s in stations["stations"].values()})
    check(
        "W13", kinds == ["유인", "자동"], f"관측소 종류가 두 가지가 아닙니다: {kinds}"
    )

    log_lines = (DATA / "field_log.txt").read_text(encoding="utf-8").splitlines()
    check(
        "W14",
        len(log_lines) == 26,
        f"현장 기록이 26줄이 아닙니다 (지금 {len(log_lines)}줄)",
    )
    check(
        "W15",
        sum(1 for line in log_lines if "결측" in line) == 4,
        "숫자로 바꿀 수 없는 값(결측)이 4줄이 아닙니다",
    )
    check(
        "W16",
        sum(1 for line in log_lines if line.strip().lower().startswith("pt")) == 2,
        "이제는 쓰지 않는 관측소(PT) 줄이 2줄이 아닙니다",
    )
    mr = [line for line in log_lines if line.strip().lower().startswith("mr")]
    check(
        "W17",
        len(mr) == 4 and all(line.rsplit("|", 1)[-1].strip() == "0.0" for line in mr),
        "물레(MR) 관측소의 현장 기록이 모두 0.0 이 아닙니다",
    )

    broken = HERE / "broken"
    for name in ("syntax_error.py", "untidy_report.py", "rainfall.py"):
        check("W18", (broken / name).is_file(), f"broken/{name} 이 없습니다")
    source = (broken / "syntax_error.py").read_text(encoding="utf-8")
    try:
        compile(source, "syntax_error.py", "exec")
        broken_ok = False
    except SyntaxError:
        broken_ok = True
    check("W19", broken_ok, "일부러 고장 낸 파일이 고쳐져 있습니다")

    examples = HERE / "examples"
    wanted_examples = [
        "hello_baramjae.py",
        "notice.py",
        "weather_note.py",
        "use_notice.py",
        "rainfall.py",
        "report.py",
    ]
    gone = [n for n in wanted_examples if not (examples / n).is_file()]
    check("W20", not gone, f"examples/ 에 없는 파일: {', '.join(gone)}")

    check("W21", (HERE / "work").is_dir(), "작업 자리(work/)가 없습니다")
    check("W22", (HERE / "out").is_dir(), "결과를 쓰는 자리(out/)가 없습니다")

    # 「없는 파일을 열면 어떻게 되는가」를 보이는 자리입니다. 이 이름은 없어야
    # 합니다 — 누군가 만들어 두면 그 예제가 오류를 내지 않게 됩니다.
    check(
        "W23",
        not (DATA / "readings_2025-12.txt").exists(),
        "없는 파일 자리로 쓰는 data/readings_2025-12.txt 가 생겨 있습니다",
    )

    report()
    return 1 if FAILURES else 0


def report():
    for line in FAILURES:
        print(line, file=sys.stderr)


if __name__ == "__main__":
    sys.exit(main())
