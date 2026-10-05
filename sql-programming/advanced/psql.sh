#!/usr/bin/env bash
# psql 열기 — 구축한 경로(기본 경로의 컨테이너 / 대안 경로의 설치)를 가려 world 데이터베이스에 붙는다.
#
# 사용법:
#   ./psql.sh                          # 대화형 psql (터미널에서)
#   ./psql.sh < review/01-reports.sql  # 파일을 흘려 넣어 실행 — 기본 경로에서도 kit 폴더의 파일을 그대로 쓸 수 있다
#   ./psql.sh -c 'SELECT count(*) FROM sales'
# 인자는 psql 에 그대로 넘긴다. 접속 데이터베이스는 world(bookstore_scale)다.
#
# 대화형으로 열면 여러분이 직접 여는 psql 과 같다 — 여러분의 ~/.psqlrc 를 읽고(대안 경로), 대안 경로에서는
# 여러분 셸의 언어 설정을 따른다. 파일을 흘려 넣거나 -c 로 부르면 kit 의 다른 스크립트처럼 -X 로 불러
# ~/.psqlrc 를 읽지 않고, psql 이 내는 문구를 영어로 고정한다.
# 이 스크립트는 bash 로 돈다 — bash 가 아닌 셸(dash 등)로 부르면 셸 자신의 오류로 끝나 kit 의 안내가 나올
# 자리가 없으므로, 먼저 확인하고 거절한다. (macOS 의 sh 는 POSIX 모드의 bash 라 그대로 돈다.)
if [ -z "${BASH_VERSION:-}" ]; then
  echo "psql 실패: 이 스크립트는 bash가 필요합니다 — 지금 셸은 bash가 아니라 psql 을 시작하지 않았습니다." >&2
  echo "  다음: ./psql.sh 또는 bash psql.sh 로 실행하세요." >&2
  exit 2
fi
set -uo pipefail
CALLER="$PWD"
cd "$(dirname "$0")"
[ -r ./kit_psql.sh ] || {
  echo "psql 실패: kit 파일 kit_psql.sh 을(를) 읽을 수 없습니다." >&2
  echo "  다음: 파일이 지워졌거나 옮겨졌다면 kit을 다시 받으세요 (0장 0.3절)." >&2
  exit 2; }
. ./kit_psql.sh
cd "$CALLER" || exit 2

kit_runtime_check "psql" 2
kit_connect_check "psql" 2

if [ -t 0 ] && [ -t 1 ] && [ $# -eq 0 ]; then
  kit_psql_tty -d "$KIT_DB"
else
  kit_psql_merged -d "$KIT_DB" "$@"
fi
