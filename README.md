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
| [open-image-prompts](https://github.com/NanmiCoder/open-image-prompts) | 보안 문제는 없음(기본 `127.0.0.1` 바인딩). 다만 Python 백엔드 + Node 20.19+ 프론트를 상시 구동하고 이미지 팩이 약 4.3GB — 저장소에 담을 성격이 아니라 로컬 머신에 직접 설치 (`npx skills add NanmiCoder/open-image-prompts -g`) |
| [claude-quest](https://github.com/Michaelliv/claude-quest) | 스킬이 아니라 Go+Raylib 기반 별도 GUI 앱. 로컬 대화 로그(JSONL)만 읽고 네트워크 호출 없음. 디스플레이 필요하므로 헤드리스 환경에서는 무용 (`npm i -g claude-quest`) |
| [Finn-loop](https://github.com/finna/Finn-loop) | Linear 워크스페이스 + 커넥터 + GitHub CLI 쓰기 권한 + 필수 CI 체크 1개 이상이 모두 전제. 선결과제가 과다하고, 필수 CI가 없으면 전건 사람 검토로 에스컬레이션되어 자동화 이점이 사라짐 |

## 라이선스

수록된 각 스킬의 원 라이선스(MIT)와 저작권 고지는 각 디렉터리의 `LICENSE` 파일을 따릅니다.
