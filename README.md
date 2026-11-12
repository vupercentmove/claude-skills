# claude-skills

스폰지클럽 멤버들을 위한 Claude Code 스킬 모음

인스타그램에서 공유된 스킬 목록을 리스크 검증(실존 여부·관리 상태·설치 스크립트·보안 이슈)한 뒤 통과한 것만 선별 수록했습니다. (1차 검증일: 2026-07-22 / 2차: 2026-08-02)

## 수록 스킬

| 경로 | 출처 | 라이선스 | 용도 |
|---|---|---|---|
| `skills/im-not-ai/` | [epoko77-ai/im-not-ai](https://github.com/epoko77-ai/im-not-ai) (v2.2, ★3.9k) | MIT | 한글 AI 티 제거 — AI가 쓴 티 나는 번역체·상투 표현을 사람 문장으로 교정 |
| `skills/frontend-slides/` | [zarazhangrui/frontend-slides](https://github.com/zarazhangrui/frontend-slides) (v2.1, ★26k) | MIT | 개요·PPTX → 의존성 없는 단일 HTML 웹 발표자료 생성 |
| `skills/draw-your-font/` | [danilo-znamerovszkij/draw-your-font](https://github.com/danilo-znamerovszkij/draw-your-font) (★524) | MIT | 손글씨 사진 → 설치 가능한 폰트(TTF/WOFF/WOFF2) 생성 |
| `skills/graph-engineering/` | [codejunkie99/graph-engineering](https://github.com/codejunkie99/graph-engineering) (★261) | MIT | 지식그래프 9단계 파이프라인 + 멀티에이전트 태스크그래프 설계 교재 |
| `design-md/` | [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md) (★104k) | MIT | 유명 브랜드 디자인 시스템 레퍼런스 (12개 브랜드 큐레이션) |

## macOS 일괄 설치 스크립트

`scripts/macmini-setup.sh`는 macOS(맥미니 기준)에서 아래를 한 번에 처리합니다.

```bash
chmod +x scripts/macmini-setup.sh && ./scripts/macmini-setup.sh

# 설치할 프로젝트 폴더를 미리 지정하려면
PROJECT_DIR=~/Work/carousel ./scripts/macmini-setup.sh
```

- Homebrew · Node 22 · Python 3.12 · Git 확인/설치 (`node@22`는 keg-only라 PATH를 `~/.zshrc`에 등록)
- [open-image-prompts](https://github.com/NanmiCoder/open-image-prompts) clone → 데이터셋 다운로드 → 로그인 자동 실행용 `autostart.command` 생성
- 이 저장소의 `draw-your-font`·`graph-engineering` 설치

**스킬은 전역(`~/.claude/skills`)이 아니라 지정한 프로젝트의 `<프로젝트>/.claude/skills/`에만 설치됩니다.** 전역에 쌓으면 모든 세션에서 로드되어 컨텍스트를 먹고 오발동 여지가 생기므로, 실제로 쓸 폴더에만 넣는 방식입니다. 따라서 해당 폴더에서 Claude Code를 실행해야 스킬이 잡힙니다.

중간에 끊어도 안전하며, 다시 실행하면 완료된 단계는 건너뜁니다. 용량이 큰 다운로드와 설치는 모두 확인을 받고 진행합니다.

> ℹ️ 데이터셋은 DB만(약 80MB) 또는 이미지 포함(약 4.3GB) 중 선택합니다. DB만 고르면 `OIP_FETCH_SKIP_IMAGES=1`이 `autostart.command`에 자동으로 반영됩니다 — 이 변수가 없으면 업스트림 `start.sh`가 실행 시마다 이미지 팩을 다시 받으려 합니다.

## 설치 방법

### im-not-ai (한글 AI 티 제거)

```bash
cd skills/im-not-ai && ./install.sh
```

`~/.claude/skills/`에 humanize-korean·humanize·humanize-redo 스킬과 전용 에이전트들이 설치됩니다. 설치 스크립트는 로컬 복사/심링크만 수행하며 외부 다운로드·API 키·훅 등록이 없습니다(직접 검수 완료). 이후 Claude Code에서 `/humanize-korean`으로 사용.

### frontend-slides (웹 발표자료)

```bash
cp -R skills/frontend-slides ~/.claude/skills/frontend-slides
```

"발표자료 만들어줘"라고 하면 자동 트리거됩니다. PPTX 변환은 `pip install python-pptx` 필요.

> ⚠️ 업스트림의 `deploy.sh`(Vercel 공개 배포)·`export-pdf.sh`(PDF 내보내기)는 미해결 보안 이슈(경로 조작)로 **제외**했습니다. 상세: [`skills/frontend-slides/scripts/SECURITY-NOTE.md`](skills/frontend-slides/scripts/SECURITY-NOTE.md)

### draw-your-font (손글씨 → 폰트)

```bash
cp -R skills/draw-your-font ~/.claude/skills/draw-your-font
```

손글씨 사진을 주면서 "이걸로 폰트 만들어줘"라고 하면 트리거됩니다. 이미지는 붙여넣기가 아니라 **파일 경로**로 줘야 합니다(터미널에 파일을 드래그하면 경로가 입력됨).

실제 폰트 생성은 npm 패키지 `draw-your-font`가 담당하고, 스킬의 `scripts/resolve-cli.js`가 이를 찾아냅니다. 전역 설치가 없으면 `npx -y draw-your-font`로 폴백하므로 별도 설치 없이 첫 실행부터 동작합니다(Node ≥ 18 필요). 매번 받는 게 싫으면 미리 깔아두세요.

```bash
npm i -g draw-your-font   # 선택 — 안 해도 npx로 동작
```

처리는 전부 로컬에서 이뤄지며 사진이 외부로 전송되지 않습니다(SKILL.md·CLI 직접 검수 완료). 생성한 폰트의 저작권은 본인에게 있고 상업적 사용이 가능합니다.

> ⚠️ **한글 미지원.** 지원 charset이 `minimal`(A–Z, a–z, 0–9, 기본 문장부호)과 `spanish`(스페인어 확장) 두 가지뿐입니다. 한글 자모·음절은 처리 대상이 아니므로 영문 로고타입·포인트 문구 용도로만 쓸 수 있습니다.

### graph-engineering (지식그래프 / 태스크그래프 설계)

```bash
cp -R skills/graph-engineering ~/.claude/skills/graph-engineering
```

실행 코드가 전혀 없는 순수 마크다운 교재형 스킬입니다. 지식그래프 9단계 파이프라인(scope → representation → ontology → entities → relations → events → quality gate → fusion → serving)과 멀티에이전트 오케스트레이션(병렬 팬아웃, 검증자 분리, 정지 규칙, 휴먼 게이트)을 다룹니다.

`WORKFLOWS.md`에 붙여넣기용 프롬프트 블록 9개가 들어 있고, 세부 이론은 `references/` 4개 파일에 분리돼 있어 필요할 때만 로드됩니다.

> ℹ️ 업스트림은 커밋 1개짜리 저장소로 유지보수 이력이 없습니다. 또 frontmatter의 `description`이 길어(약 5줄) 세션마다 상시 로드되는 비용이 있습니다 — 본문은 트리거될 때만 읽히지만, 안 쓸 거라면 설치하지 않는 편이 낫습니다. 패키지본(`dist/graph-engineering.skill`)은 이 디렉터리와 내용이 중복되어 제외했습니다.

### design-md (브랜드 디자인 레퍼런스)

원하는 브랜드의 `DESIGN.md` 한 개를 작업 중인 프로젝트 루트에 복사한 뒤 "이 DESIGN.md 스타일로 만들어줘"라고 지시합니다. 실행 코드가 전혀 없는 순수 마크다운입니다.

```bash
cp design-md/nike/DESIGN.md ./DESIGN.md
```

수록 브랜드: nike · airbnb · apple · pinterest · shopify · spotify · starbucks · stripe · notion · linear.app · figma · vercel
(전체 73개는 업스트림 참고. 한국 브랜드는 미포함 — "토스처럼"은 이 저장소로는 불가)

> ⚠️ 브랜드 디자인 레퍼런스는 커뮤니티가 공개 CSS에서 추출한 비공식 자료입니다. 특정 브랜드의 룩을 상업 결과물에 통째로 복제하면 트레이드 드레스 이슈가 될 수 있으니 참고용으로만 사용하세요.

## 검증 후 보류/제외한 스킬

| 스킬 | 사유 |
|---|---|
| oh-my-design | npx 설치기가 상시 훅(SessionStart 등)을 등록, 1인 관리 저장소 — 훅 검수 후 개별 판단 |
| claude-seo | bash 설치기 + Python + 헤드리스 크롬 실행 툴체인 — SEO 본격화 시 재검토 |
| n8n-skills | 신뢰도는 높으나 n8n-mcp 서버 + n8n 인스턴스/API 키 전제 |
| OpenMontage | 스킬이 아닌 풀 영상 제작 앱(Python/FFmpeg/Remotion), 최근 커맨드 인젝션 패치 이력 |
| chromux | ★38개·5주차 신생 프로젝트, 라이브 모드가 로그인된 실제 브라우저를 무인증 로컬 브리지로 노출 |
| [open-image-prompts](https://github.com/NanmiCoder/open-image-prompts) | 코드 감사 통과 — 모든 다운로드에 sha256 검증, 바인딩 `127.0.0.1` 고정, 루트 npm 의존성 0개, 파이썬은 프로젝트 내 `.venv`로 격리. 다만 Python 백엔드 + Node 20.19+ 프론트를 상시 구동하고 이미지 팩이 약 4.3GB라 저장소에 담을 성격이 아님 → `scripts/macmini-setup.sh`로 로컬 설치 |
| [claude-quest](https://github.com/Michaelliv/claude-quest) | 스킬이 아니라 Go+Raylib 기반 별도 GUI 앱. 로컬 대화 로그(JSONL)만 읽고 네트워크 호출 없음. 디스플레이 필요하므로 헤드리스 환경에서는 무용 (`npm i -g claude-quest`) |
| [Finn-loop](https://github.com/finna/Finn-loop) | Linear 워크스페이스 + 커넥터 + GitHub CLI 쓰기 권한 + 필수 CI 체크 1개 이상이 모두 전제. 선결과제가 과다하고, 필수 CI가 없으면 전건 사람 검토로 에스컬레이션되어 자동화 이점이 사라짐 |

## 공식 플러그인 검토 (3차: 2026-11-12)

인스타 공유자료 "클로드 안에 크리에이티브 팀 만들기"의 7개 항목을 원본 저장소([anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official), [remotion-dev/skills](https://github.com/remotion-dev/skills))를 직접 열어 검토했습니다. 이 저장소에 파일로 담을 대상이 아니라 Claude Code 안에서 `/plugin install`로 설치하는 항목이라, 판정만 기록합니다.

| 항목 | 판정 | 근거 |
|---|---|---|
| frontend-design | **설치 권장** | 마크다운 스킬 1개(실행 코드 없음). Next.js 랜딩 작업에 바로 쓰임. 화면 작업하는 프로젝트에만 설치 |
| Playwright MCP | **설치 권장 (조건부)** | Microsoft 공식, 활발히 관리됨(0.0.85, 2026-11-09). 자사 페이지 테스트·화면 확인용으로 설치. 경쟁몰 대량 수집은 약관 위반 소지가 있어 쓰지 않음. 공식 설정은 `@latest`라 실행할 때마다 버전이 바뀜 → 직접 등록할 때는 버전 고정 |
| claude-code-setup | 선택 | 읽기 전용 추천 스킬 1개, 위험 없음. 새 개발 프로젝트를 시작할 때만 쓸모가 있음 |
| security-guidance | **보류** | v2.0.19부터 단순 패턴 경고가 아님: 매 응답 종료(Stop)·커밋마다 최신 Opus로 diff 리뷰를 돌려 **사용량을 계속 소모**하고, 첫 실행 때 `~/.claude/security/`에 venv를 만들어 Agent SDK를 pip 설치함. 코드 리뷰는 Codex가 맡고 있으므로 배포 전 내장 `/security-review`로 대체. 고객정보·결제 프로젝트에서만 `ENABLE_STOP_REVIEW=0`으로 설치 검토 |
| Remotion | **보류 (라이선스 확인)** | 직원 4명 이상인 영리법인은 유료 Company License 필요([LICENSE.md](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md)). Remotion 5.0에서 라이선스 변경 예고. 스킬이 아니라 Node 영상 프로젝트라 세팅 부담이 큼 |
| Discord 채널 | **제외** | Bun 설치·봇 토큰·집 컴퓨터 상시 실행이 전제. 폰에서 지시하는 기능은 Claude 앱 원격 세션·Remote Control로 이미 가능 |
| skill-creator | **제외 (보유 중)** | 이미 `anthropic-skills:skill-creator`로 쓰는 중 |

## 라이선스

수록된 각 스킬의 원 라이선스(MIT)와 저작권 고지는 각 디렉터리의 `LICENSE` 파일을 따릅니다.
