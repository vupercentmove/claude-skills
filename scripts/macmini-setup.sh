#!/bin/bash
# 맥미니 스킬 설치 스크립트
#
# 설치 대상
#   1. open-image-prompts  — 이미지 프롬프트 아카이브 (로컬 웹 갤러리 + 에이전트 스킬 2종)
#   2. claude-quest        — Claude Code 세션 픽셀아트 뷰어 (선택)
#   3. claude-skills 저장소 — draw-your-font + graph-engineering 스킬
#
# 스킬은 전역(~/.claude/skills)이 아니라 지정한 프로젝트 폴더의
# <프로젝트>/.claude/skills 안에만 설치됩니다. 다른 작업에서는 로드되지
# 않으므로 컨텍스트를 먹지 않고 오발동도 생기지 않습니다.
#
# 사용법
#   chmod +x macmini-setup.sh && ./macmini-setup.sh
#
#   프로젝트 경로를 미리 지정하려면:
#   PROJECT_DIR=~/Work/carousel ./macmini-setup.sh
#
# 도중에 멈춰도 안전합니다. 다시 실행하면 이미 끝난 단계는 건너뜁니다.

set -euo pipefail

DEV_DIR="${DEV_DIR:-$HOME/Dev}"
PROJECT_DIR="${PROJECT_DIR:-}"

# ── 출력 헬퍼 ────────────────────────────────────────────────
step() { printf '\n\033[1;34m▸ %s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
die()  { printf '  \033[31m✗ %s\033[0m\n' "$1" >&2; exit 1; }
ask() {
  local reply
  read -r -p "  $1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ── 스킬을 설치할 프로젝트 폴더 ──────────────────────────────
step "스킬을 설치할 프로젝트 폴더 지정"
echo "  스킬은 전역이 아니라 이 폴더의 .claude/skills/ 안에만 설치됩니다."
echo "  Claude Code를 이 폴더에서 실행할 때만 로드됩니다."
echo
if [ -z "$PROJECT_DIR" ]; then
  read -r -p "  경로 (엔터 = $HOME/Work/carousel): " PROJECT_DIR
  PROJECT_DIR="${PROJECT_DIR:-$HOME/Work/carousel}"
fi
# ~ 확장 + 절대경로화
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
mkdir -p "$PROJECT_DIR"
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
SKILLS_DIR="$PROJECT_DIR/.claude/skills"
mkdir -p "$SKILLS_DIR"
ok "설치 위치: $SKILLS_DIR"

# ── 0. Homebrew ─────────────────────────────────────────────
step "Homebrew 확인"
if command -v brew >/dev/null 2>&1; then
  ok "설치됨 ($(brew --version | head -1))"
else
  warn "Homebrew가 없습니다. 설치합니다 (관리자 암호를 물어봅니다)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon / Intel 경로 모두 대응
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1 || die "Homebrew 설치 실패"
  ok "Homebrew 설치 완료"
fi

BREW_PREFIX="$(brew --prefix)"

# ── 1. Node 22 + Python + Git ───────────────────────────────
step "Node 22 / Python 3.12 / Git 설치"
for pkg in node@22 python@3.12 git; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "$pkg 이미 설치됨"
  else
    brew install "$pkg"
    ok "$pkg 설치 완료"
  fi
done

# node@22 는 keg-only 라 PATH에 직접 넣어야 합니다
NODE_BIN="$BREW_PREFIX/opt/node@22/bin"
export PATH="$NODE_BIN:$PATH"

SHELL_RC="$HOME/.zshrc"
if ! grep -q 'opt/node@22/bin' "$SHELL_RC" 2>/dev/null; then
  printf '\n# node@22 (open-image-prompts 요구사항)\nexport PATH="%s:$PATH"\n' "$NODE_BIN" >> "$SHELL_RC"
  ok "$SHELL_RC 에 node@22 PATH 추가"
else
  ok "$SHELL_RC 에 node@22 PATH 이미 있음"
fi

step "버전 검증"
NODE_V="$(node -v 2>/dev/null || echo none)"
ok "node   $NODE_V"
ok "python $(python3 --version 2>&1 | awk '{print $2}')"
ok "git    $(git --version | awk '{print $3}')"

# open-image-prompts 요구: 20.19+ 또는 22.12+
node -e '
  const [maj, min] = process.versions.node.split(".").map(Number);
  const ok = (maj === 20 && min >= 19) || (maj === 22 && min >= 12) || maj > 22;
  if (!ok) { console.error("need Node 20.19+ or 22.12+"); process.exit(1); }
' || die "Node 버전이 요구사항($NODE_V)에 못 미칩니다. 'brew upgrade node@22' 후 재실행하세요."
ok "Node 버전 요구사항 충족"

# ── 2. open-image-prompts ───────────────────────────────────
step "open-image-prompts 설치"
mkdir -p "$DEV_DIR"
OIP_DIR="$DEV_DIR/open-image-prompts"

if [ -d "$OIP_DIR/.git" ]; then
  ok "이미 clone 되어 있음 — 최신으로 갱신"
  git -C "$OIP_DIR" pull --ff-only || warn "pull 실패 (로컬 변경사항이 있을 수 있음) — 건너뜁니다"
else
  git clone https://github.com/NanmiCoder/open-image-prompts.git "$OIP_DIR"
  ok "clone 완료"
fi

cd "$OIP_DIR"

step "데이터셋 다운로드"
echo "  A) DB만 받기        — 약 80MB. 검색·프롬프트 조회 전부 동작."
echo "                        이미지는 원본 URL로 폴백되어 갤러리 로딩이 느립니다."
echo "  B) 이미지까지 받기  — 약 4.3GB. 오프라인에서도 즉시 로딩."
echo
echo "  처음이라면 A를 권합니다. 써보고 나서 B로 올려도 늦지 않습니다."
echo "  (나중에 올리려면 이 디렉터리에서 'npm run data:pull')"
echo
if ask "이미지까지 전부 받으시겠습니까? (약 4.3GB, 시간 오래 걸림)"; then
  SKIP_IMAGES=0
  npm run data:pull
  ok "전체 데이터셋 다운로드 완료"
else
  SKIP_IMAGES=1
  npm run data:pull:db
  ok "DB만 다운로드 완료 (~80MB)"
  warn "주의: start.sh 는 기본적으로 이미지까지 받으려 합니다."
  warn "      DB만 쓰려면 OIP_FETCH_SKIP_IMAGES=1 을 항상 붙여야 합니다."
  warn "      아래에서 만드는 autostart.command 에는 자동으로 반영됩니다."
fi

step "설치 상태 확인"
export OIP_REPO_ROOT="$PWD"
npm run status || warn "status 확인 실패 — 첫 실행 시 문제가 있으면 이 출력을 확인하세요"

step "에이전트 스킬 등록 (img-gen-taste / img-gen-prompts)"
echo "  설치 위치: $SKILLS_DIR  (전역 아님)"
if ask "두 스킬을 이 프로젝트에 등록할까요?"; then
  # -g 를 붙이지 않으면 현재 작업 디렉터리 기준으로 설치됩니다
  ( cd "$PROJECT_DIR" && npx skills add NanmiCoder/open-image-prompts )
  ok "프로젝트 스킬로 등록 완료"
else
  warn "건너뜀 — 나중에: cd $PROJECT_DIR && npx skills add NanmiCoder/open-image-prompts"
fi

# ── 3. 자동 실행 등록 ────────────────────────────────────────
step "로그인 시 자동 실행 등록"
AUTOSTART="$OIP_DIR/autostart.command"
{
  echo '#!/bin/bash'
  echo "export PATH=\"$NODE_BIN:\$PATH\""
  if [ "$SKIP_IMAGES" = "1" ]; then
    echo '# DB만 사용 — 이 변수가 없으면 start.sh 가 4.3GB 이미지를 받으려 합니다'
    echo 'export OIP_FETCH_SKIP_IMAGES=1'
  fi
  echo "cd \"$OIP_DIR\" && ./start.sh"
} > "$AUTOSTART"
chmod +x "$AUTOSTART"
ok "생성됨: $AUTOSTART"
echo "     시스템 설정 → 일반 → 로그인 항목 에 위 파일을 드래그해 넣으면"
echo "     맥미니를 켤 때마다 자동으로 뜹니다. (수동 실행: ./start.sh)"

# ── 4. claude-quest (선택) ──────────────────────────────────
step "claude-quest (픽셀아트 세션 뷰어)"
if command -v cq >/dev/null 2>&1; then
  ok "이미 설치됨"
elif ask "설치할까요? 작업 효율과는 무관한 시각화 도구입니다"; then
  npm install -g claude-quest
  ok "설치 완료 — Claude Code 실행 중에 새 터미널 탭에서 'cq'"
else
  warn "건너뜀 — 나중에: npm install -g claude-quest"
fi

# ── 5. claude-skills 저장소 스킬 ────────────────────────────
step "claude-skills 저장소 스킬 (draw-your-font / graph-engineering)"
CS_DIR="$DEV_DIR/claude-skills"

if [ -d "$CS_DIR/.git" ]; then
  git -C "$CS_DIR" pull --ff-only || warn "pull 실패 — 수동 확인 필요"
  ok "저장소 갱신 완료"
else
  git clone https://github.com/vupercentmove/claude-skills.git "$CS_DIR"
  ok "clone 완료"
fi

mkdir -p "$SKILLS_DIR"
for skill in draw-your-font graph-engineering; do
  if [ -d "$CS_DIR/skills/$skill" ]; then
    rm -rf "${SKILLS_DIR:?}/$skill"
    cp -R "$CS_DIR/skills/$skill" "$SKILLS_DIR/$skill"
    ok "$skill → $SKILLS_DIR/$skill"
  else
    warn "$skill 을 저장소에서 찾지 못했습니다 — 건너뜀"
  fi
done

# ── 완료 ────────────────────────────────────────────────────
cat <<EOF

$(printf '\033[1;32m─── 설치 완료 ───\033[0m')

  다음 단계

  1. 새 터미널 탭을 여세요 (PATH 변경 반영)

  2. 갤러리 실행
       cd $OIP_DIR && $([ "$SKIP_IMAGES" = "1" ] && echo 'OIP_FETCH_SKIP_IMAGES=1 ')./start.sh
     브라우저에서  http://localhost:5173
     포트가 겹치면  OIP_WEB_PORT=5273 를 앞에 추가

     첫 실행 때 start.sh 가 uv(파이썬 관리자)를 받아옵니다. 시스템이 아니라
     $OIP_DIR/.oip/tools/uv 안에만 설치되고 PATH를 건드리지 않습니다.
     파이썬 가상환경도 프로젝트 안 .venv 로 격리됩니다.

  3. 상시 실행하려면
     시스템 설정 → 일반 → 로그인 항목 에
     $AUTOSTART 추가

  4. 설치된 스킬 — $SKILLS_DIR
       img-gen-taste       크리에이티브 브리프 → 아트디렉션
       img-gen-prompts     프롬프트-이미지 대조 갤러리
       draw-your-font      손글씨 사진 → 폰트 (영문 전용, 한글 미지원)
       graph-engineering   지식그래프 / 태스크그래프 설계 교재

     전역이 아니므로 반드시 프로젝트 폴더에서 Claude Code를 실행해야
     로드됩니다:
       cd $PROJECT_DIR && claude

     다른 폴더에서도 쓰고 싶어지면 그 폴더에 심링크를 거세요
     (사본이 늘어나지 않아 업데이트가 한 곳에서 끝납니다):
       mkdir -p <다른폴더>/.claude
       ln -s "$SKILLS_DIR" <다른폴더>/.claude/skills

     설치된 스킬 확인:
       ls $SKILLS_DIR

  참고
  - 갤러리는 127.0.0.1 에만 바인딩되어 맥미니 밖에서는 안 보입니다.
    다른 기기에서 보려면 바인딩을 여는 대신 SSH 포워딩을 쓰세요:
      ssh -L 5173:localhost:5173 <맥미니주소>
  - 손글씨 폰트는 파일 경로가 필요합니다. 터미널에 이미지를 드래그하면
    경로가 입력됩니다 (붙여넣기로는 동작하지 않습니다).

EOF
