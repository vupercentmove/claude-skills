# marketingskills 설치 & 검증 리포트

- 출처: [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)
- 버전: 2.10.0 (최신 커밋 2026-07-27)
- 라이선스: MIT (© Corey Haines)
- 검증일: 2026-07-29
- 규모: 스킬 49개, 저장소 4.6MB (`.git` 제외)

## 설치 방법

레퍼런스 글이 소개한 3가지 방법 모두 유효하다.

```bash
# 1) CLI (실제 사용한 방법)
npx skills add coreyhaines31/marketingskills

# 2) Claude Code 플러그인
/plugin marketplace add coreyhaines31/marketingskills
/plugin install marketing-skills

# 3) 수동
git clone https://github.com/coreyhaines31/marketingskills
cp -R marketingskills/skills/* ~/.claude/skills/
```

### 설치 위치 주의 (글에서 언급된 "엉뚱한 폴더" 이슈)

`npx skills add`를 **에이전트 세션 안에서** 실행하면 비대화형으로 돌아서, 범용 경로인
`.agents/skills/`에만 깔리고 Claude Code가 읽는 경로에는 안 들어갈 수 있다. 업스트림
README도 이 점을 경고한다.

이번 설치 결과는 아래와 같았다.

```
.agents/skills/<skill>/     # 실제 파일 (49개)
.claude/skills/<skill>  ->  ../../.agents/skills/<skill>   # 심링크
skills-lock.json            # 소스 + SHA256 해시 잠금
```

`.claude/skills/`에 심링크가 걸려서 Claude Code가 정상 인식한다. 만약 심링크가 없다면:

```bash
npx skills add coreyhaines31/marketingskills --agent claude-code
```

또한 이건 **프로젝트 로컬 설치**다. 어느 프로젝트에서나 쓰려면 `~/.claude/skills/`로 복사할 것.

## 보안 검증

| 항목 | 결과 |
|---|---|
| install.sh 등 설치 스크립트 | 없음 (npx CLI가 파일 복사만 수행) |
| 훅(hook) 등록 / settings.json 변조 | 없음 |
| 설치 중 외부 다운로드·코드 실행 | 없음 |
| 스킬 본문의 `curl` | 있음 — 전부 공개 API 읽기용 예시(Google News RSS, HN Algolia, Bluesky 공개 API, YouTube 피드). 실행은 사용자 지시가 있어야만 일어남 |
| `tools/clis/` (65개 Node 스크립트) | 각 SaaS 공식 API 호스트로만 요청. 키는 `process.env.*`로 읽고 어디에도 재전송하지 않음 |
| eval / child_process / 난독화 | 없음 |
| 무결성 | `skills-lock.json`에 스킬별 SHA256 기록 → 변조 감지 가능 |

결론: **설치 자체는 안전**. 실행 코드는 사실상 마크다운 + 사용자가 명시적으로 부를 때만 도는 CLI 래퍼뿐이다.

## 장점

1. **커버리지가 압도적이다.** CRO, 카피라이팅, SEO/AI SEO, 유료광고, 광고 크리에이티브, 콜드메일,
   프로스펙팅, 가격정책, 리퍼럴, 처닝 방어, PR, 오퍼 설계까지 49개. 마케팅 워크플로 대부분이 커버된다.
2. **description이 잘 짜여 있다.** 트리거 문구를 구어체까지 나열하고("이 랜딩페이지 왜 안 되지"류),
   관련 스킬로의 라우팅까지 명시("팝업은 popups로") — 자동 발동 정확도가 높다.
3. **분량이 아니라 기준을 준다.** 예: `cro`는 밸류 프롭 → 헤드라인 → CTA → 시각 위계 → 신뢰 신호 →
   반론 처리 순으로 *임팩트 순서*가 고정돼 있다. 글의 요지 그대로 "판단 기준"이 생긴다.
4. **progressive disclosure 구조.** SKILL.md는 얇게, 세부는 `references/`로 분리 → 컨텍스트 낭비가 적다.
5. **`evals/evals.json`이 스킬마다 있다.** 기대 출력이 문서화돼 있어 커스터마이징 후 회귀 검증이 가능하다.
   (우리가 스킬을 고칠 때 그대로 재활용 가능)
6. **관리 상태 양호.** v2.10.0, 최신 커밋 2일 전, MIT, PR 템플릿·CI 검증 워크플로 보유.
7. **툴 연동 문서 100여 개.** GA4, Meta Ads, Klaviyo, Ahrefs 등 API 연결 레시피가 붙어 있어
   "분석까지 자동화" 단계로 확장 가능.

## 단점 / 주의사항

1. **전부 영어다.** 스킬 본문·프레임워크·예시가 영어라 한국어로 답을 받으려면 매번 명시해야 하고,
   카피 관련 스킬(`copywriting`, `emails`, `sms`, `social`)은 **영어 카피 관용구 기준**이라
   한국어 카피에 그대로 쓰면 번역체가 나온다. → 우리 `im-not-ai`(humanize-korean)와 병용 필요.
2. **B2B SaaS 편향.** ICP·free trial·데모 요청·PLG 기준이 기본값이다. 여성의류/D2C 커머스 맥락에는
   "무료 체험" 같은 전제가 안 맞는 대목이 있어 프롬프트에서 업종을 먼저 못 박아야 한다.
3. **49개 동시 설치는 과하다.** description 49개가 상시 로드되고, 이름이 겹치는 스킬
   (`ads` vs `ad-creative`, `competitors` vs `competitor-profiling`, `cro` vs `signup` vs `onboarding` vs `popups`)이
   많아 오발동 여지가 있다. **필요한 8~12개만 골라 설치**를 권장한다.
   ```bash
   npx skills add coreyhaines31/marketingskills --skill cro copywriting social ads offers pricing marketing-psychology customer-research
   ```
4. **개별 SKILL.md가 크다.** ai-seo 27KB, ads 25KB, marketing-psychology 22KB. 발동되는 순간
   컨텍스트를 크게 먹으므로 긴 세션에서는 체감된다.
5. **`marketing-council`은 실존 인물 페르소나 12명**(오길비, 호르모지, 세스 고딘 등)을 흉내 낸다.
   내부 아이디에이션용으로는 유용하지만, 산출물을 그대로 대외 발행하면 곤란하다.
6. **툴 CLI는 사실상 미검증 영역.** 65개 스크립트에 각 SaaS API 키를 넣는 구조다. 안전하게 짜여 있긴 하나,
   **실제 계정 키를 붙일 때는 읽기 전용 권한부터** 시작할 것. 광고비를 집행하는 API(`google-ads`, `meta-ads`)는
   특히 주의.
7. **저자 1인 프로젝트.** 버스 팩터 1. 업스트림이 멈추면 그대로 멈춘다. 우리가 쓰는 스킬은
   포크해두는 편이 안전하다.

## 선별 설치 결정 (2026-07-29)

49개 전체를 깔았다가 **12개만 남겼다.** `skills-lock.json`이 이 12개 기준으로 갱신돼 있다.

```bash
npx skills add coreyhaines31/marketingskills --skill \
  product-marketing customer-research marketing-psychology \
  cro offers copywriting social ads ad-creative \
  analytics ab-testing marketing-plan
```

| 스킬 | 남긴 이유 |
|---|---|
| `product-marketing` | 나머지 11개가 참조하는 컨텍스트 파일 생성. 제일 먼저 돌린다 |
| `customer-research` | 고객 언어 확보 — 카피의 재료 |
| `marketing-psychology` | 판단 근거. 언어 의존도가 낮아 그대로 쓸 수 있다 |
| `cro` | 페이지 진단 순서 고정. 즉효성 1위 |
| `offers` | 보너스·보장·희소성 — 커머스/D2C에 직결 |
| `copywriting` | 구조만 차용 (문장은 한국어로 다시 씀) |
| `social` | 캐러셀·숏폼 프레임워크 |
| `ads` / `ad-creative` | 캠페인 전략 + 소재 대량 생성 |
| `analytics` | GA4/GTM 이벤트 설계 |
| `ab-testing` | "감으로 바꿨다" 방지 |
| `marketing-plan` | 클라이언트 제안용 AARRR 종합 플랜 |

제외한 37개는 필요할 때 `--skill <이름>`으로 개별 추가하면 된다. 주요 제외 사유:

- `signup`·`onboarding`·`paywalls`·`churn-prevention`·`pricing` — B2B SaaS 구독 전제라 D2C 커머스와 안 맞음
- `emails`·`sms`·`cold-email` — 영어 관용구 + 미국 규제(CAN-SPAM/TCPA) 기준
- `content-strategy` — 우리 `insight-note-creator`·`carousel-copy-generator`와 역할 중복
- `competitors` vs `competitor-profiling`, `ads` vs `ad-creative` 류 — 이름이 겹쳐 오발동 유발
- `marketing-council` — 실존 인물 페르소나, 대외 산출물 부적합
- `seo-audit`·`ai-seo`·`schema`·`programmatic-seo` 등 — SEO 본격화 시 재검토

결과: 49개 → 12개, `.agents/skills` 용량 4.6MB → 1.1MB.

## 뷰퍼센트무브 관점의 권장 사용법

- **바로 쓸 만한 것**: `cro`, `customer-research`, `marketing-psychology`, `offers`, `pricing`,
  `analytics`, `ab-testing` — 언어 의존도가 낮고 "판단 기준" 성격이 강하다.
- **한국어 보정 필수**: `copywriting`, `emails`, `sms`, `social` — 구조만 빌리고 문장은 우리 원칙
  (성희님 8원칙 / 오문 콘텐츠 기준)으로 다시 쓴다.
- **첫 프롬프트**는 글의 제안대로 "새 글 생성"이 아니라 **기존 페이지 진단**으로 시작하는 게 맞다.
  수정안보다 질문을 먼저 받게 유도하면 우리 제품/고객 맥락이 주입돼 결과가 확연히 좋아진다.
- 우리 기존 스킬(`brand-strategist`, `content-quality-checker`)과 **판단 기준이 충돌**할 수 있다.
  전략 판단은 우리 스킬, 실행 체크리스트는 marketingskills로 역할을 나누는 게 낫다.
