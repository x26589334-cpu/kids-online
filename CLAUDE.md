# 키즈튜터 — 유아·초등 화상과외 사이트 (이어서 작업용)

## 개요
- 5세~초6 대상 **1:1 화상과외** 홍보 사이트. 정적 HTML/CSS/JS, GitHub Pages 배포 (gwaoe-page / wawa-renewal 과 같은 형식)
- **브랜드:** 키즈튜터 (티칭코칭 perfectedu.co.kr 의 유아·초등 서비스. 사이트 안에서 티칭코칭은 모회사로만 언급)
- **도메인:** https://kidstutor.co.kr (가비아 구매, `CNAME` 파일 있음). GitHub Pages 브랜치: **main**
- **상담 전화:** 010-6832-1994 (티칭코칭과 동일)

## 배포 방법
```
git add .
git commit -m "메시지"
git push
```
→ GitHub Pages 설정 후 1~2분 뒤 반영. (저장소·Pages 설정은 아래 "처음 배포" 참고)

## 파일 구조
- `index.html` — 홈 (히어로 / 연령별 탭 `#ages` / **수업방식 `#process`** = 프로그램 6종·준비물·수업 길이표·진행 흐름·한 회차 / 걱정 해결 / 선생님 미리보기 / 후기 / FAQ / 신청 폼)
- `teachers.html` — 선생님 찾기 (검색 + 필터: 대상(유아·아동 코칭 경력/초1부터)/과목/성별/수업형태, 24명씩 페이지네이션). `?s=영어`, `?kid=1` 로 필터 진입 가능
- `teacher-{id}.html` — 선생님 개별 페이지 (**gen.ps1 로 자동 생성**, 손으로 고치지 말 것)
- `process.html` — **리다이렉트 전용** (2026-09-05 내용을 홈 `#process` 로 통합). 선생님 515장·블로그·검색엔진이 링크해서 파일은 남김. sitemap 에서 뺐고 gen.ps1 `$known` 에 있어 자동으로 다시 들어가지도 않음
- `teachers-data.js` — `window.TEACHERS=[{i,n,g,c,s,gr,r,sd,k}]` (gen.ps1 생성. k=1 이면 유아·아동 코치)
- `teachers-search.js` — 검색 색인 `window.TSEARCH` (gen.ps1 생성, defer 로드)
- `style.css` — gwaoe-page/style.css 를 복사해 토큰만 키즈 팔레트로 바꾸고, 끝에 "키즈 전용 추가" 블록을 붙인 것
  - ⚠️ 수정 시 전 페이지의 `style.css?v=` 숫자 올리기 (현재 v3)
- `script.js` — gwaoe-page 와 동일 (reveal, paginate)
- `form.js` — 신청 폼 → 구글 시트. 과외(gwaoe-page)·공부의온도(tutoring-site)·채용(vine-recruit)·데일리카네기·서포트포스(pickpos)와 **같은 공용 웹앱 하나**(총 6개 사이트) → "웹 문의" 시트의 **"키즈 튜터" 탭**(띄어쓰기 포함, `sheet=키즈 튜터` 전송, 구분 `키즈튜터-무료체험신청` 등)
  - 실제 스크립트는 **구글 서버**(script.google.com, 계정 x26589334@gmail.com)에 있음. 저장소의 `google-apps-script.gs` 는 **참고용 사본이라 고쳐도 동작 안 바뀜**
  - 배포본에 **허용 탭 목록이 없어서** `sheet` 값이 그대로 탭 이름이 됨 → 오타 시 기본 탭("과외")으로 안 가고 **새 탭이 조용히 생김**. 탭 이름 건드렸으면 실제 시트 확인 필수
  - 2026-09-03 실제 제출 테스트로 "키즈 튜터" 탭 정상 도착 확인 (폼 3종·선생님 페이지 515개 전부 정상)
- `gen.ps1` — 선생님 데이터/페이지/sitemap 생성기 · `make-images.ps1` — og-image.png / apple-touch-icon.png 생성기
- `sitemap.xml` (gen.ps1 생성) / `robots.txt` / `favicon.svg`
- **상단 메뉴 5개** (2026-09-05 정리): 홈 · 선생님 찾기 · 수업방식(`index.html#process`) · 블로그 · 자주 묻는 질문. 연령별·프로그램·학부모 후기는 메뉴에서 뺐지만 섹션은 홈에 남아 있음. 메뉴는 `gen.ps1` 의 `$header` 템플릿에도 있으니 바꿀 땐 같이 바꿀 것
- `favicon.svg` = 마스코트 **키투** (index.html 히어로 인라인 SVG 와 같은 도형, 그림자만 뺌). `apple-touch-icon.png` 는 `make-images.ps1` 산출물이라 아직 옛 "K" 로고 — 바꾸려면 그 스크립트를 고쳐야 함

## 디자인
- 팔레트: 주황 `--brand:#ff7a1f` / 살구 `--brand-2:#ffa94d` / 민트 `--accent:#1fb59b` / 노랑 `--sun:#ffd166` / 잉크 `#1e2a3f` / 바탕 `#fff7ee`
- 서체: 제목 **Jua**(Google Fonts) + 본문 Pretendard. 각 페이지 head 에 Jua link 있음
- 레이아웃·컴포넌트 클래스는 perfectedu 와 동일 (`.hero .hero-card .trust .cards .steps .why .feat .quotes .faq .apply .tgrid .tc .tprofile .tcard .tsec` …) + 키즈 전용 `.screen .age-tabs .age-panel .lesson .flow .tform`

## 선생님 데이터 (gen.ps1)
- 원본: `../gwaoe-page/teachers-data.js`, `teachers-search.js`, `teacher-{id}.html` (와와/티칭코칭 코치 750명)
- **선택 기준:** 화상 가능(`c` 에 "화상") AND (유아·아동 코치 `k=1` OR 어떤 과목이든 학년이 유아·초등(초1~6)부터)
  → 명수는 gen.ps1 실행 출력 참고 (유아·아동 코치 30명 먼저, 이후 원래 순서). index.html 히어로의 "N+" 숫자도 같이 맞출 것
- 개별 페이지는 원본 페이지의 "선생님 소개 / 지도 과목 / 경력" 섹션을 그대로 가져오고, 방문 지역·학교 목록은 뺌 (방문+화상 선생님은 지역명만 한 줄)
- **재생성:** gwaoe-page 의 선생님 데이터가 바뀌면 아래 실행 (PowerShell 5.1 은 BOM 없는 .ps1 의 한글이 깨지므로 BOM 붙여 실행)
  ```
  printf '\xEF\xBB\xBF' | cat - gen.ps1 > gen_bom.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File gen_bom.ps1 && rm gen_bom.ps1
  ```
  (index.html 의 "360+" 숫자는 손으로 맞출 것)

## 처음 배포 (아직 안 했으면)
1. GitHub 에 `kids-online` 저장소 생성: `gh repo create kids-online --public --source=. --push` (gh 는 `C:\Program Files\GitHub CLI\gh.exe`)
2. 저장소 Settings → Pages → Branch: main / (root)
3. 도메인 연결 시 `CNAME` 파일에 도메인 한 줄 + DNS 에 CNAME 레코드(`x26589334-cpu.github.io`)


## 블로그 (SEO 콘텐츠) — 2026-09-04 신설
- `blog.html` — 글 목록. 맨 위 주석에 **새 글 카드 추가 형식**이 그대로 들어 있으니 복사해서 `blogList` 맨 위에 붙이면 됨
- 글 파일 10편 — `hangul-*.html`·`number-*.html` 5편(국내 유아 한글떼기·숫자놀이), `overseas-*.html` 5편(해외 거주 가정). 새 글은 **기존 글 하나를 복사해서 내용만 교체**하는 게 가장 빠름
- **묶음 균형을 보세요.** 한 묶음만 몰아 쓰면 사이트 성격이 그쪽으로만 보입니다(해외 5편만 있을 때 재외국민 전용처럼 보였음). 주 단위로 묶음을 바꾸되 국내:해외 비중을 유지할 것
- 글 한 편 규격: 본문 2,000~3,000자 · `<h2>` 3~4개 · `.article` 클래스 · 끝에 `.hl-box` + "이런 글도 함께 보세요"(같은 묶음 글끼리 내부 링크) + CTA 섹션
- **CSS는 추가로 안 써도 됨.** `.blog .bpost .article .hl-box` 가 style.css 에 이미 있음(gwaoe-page 에서 복사됨) + 스티커북 테마도 함께 적용됨

### ⚠️ sitemap 함정 (2026-09-04 수정 완료)
`gen.ps1` 은 sitemap.xml 을 **통째로 다시 쓴다.** 원래는 홈·teachers·process·teacher-*.html 만 넣어서,
블로그 글을 아무리 써도 `gen.ps1` 을 한 번 돌리면 sitemap 에서 전부 사라졌다(파일은 남아서 눈치 못 챔).
→ 지금은 폴더의 `*.html` 을 훑어서 자동으로 넣도록 고쳐 놨으므로 **새 글을 추가해도 gen.ps1 을 손댈 필요 없다.**
이 블록(`$extra` 변수 부분)을 지우면 함정이 되살아나니 건드리지 말 것.


### ⚠️ 고아 페이지 함정 (2026-09-11 수정 완료)
`teachers.html` 은 선생님 목록을 **자바스크립트로 그린다.** 그래서 HTML 원본에는
`teacher-*.html` 로 가는 링크가 하나도 없다. 동네 페이지에서 닿는 건 **방문 가능한 131명뿐**이라,
나머지 384명은 어느 페이지에서도 링크되지 않는 **고아 페이지**였다(사이트맵에만 존재).
구글은 이런 주소를 "검색됨 – 현재 색인이 생성되지 않음" 으로 미루고, 네이버 봇은 JS 를 거의 실행하지 않아 더 불리하다.
→ `gen.ps1` 이 **`teachers-all.html`(전체 선생님 목록, 515개 링크)** 을 만들고 **전 페이지 푸터**에서 연결한다.
새 선생님이 늘어도 `gen.ps1` 만 돌리면 자동 반영된다. 푸터의 `전체 선생님 목록` 링크를 지우면 함정이 되살아난다.

### ⚠️ PowerShell 함수 호출 함정
`$x = Esc("a") + " <b>" + Esc("c")` 는 **Esc 에 인자 3개를 넘기는 명령 호출**로 파싱된다(결과: 첫 인자만 처리됨).
에러도 안 나고 조용히 뒷부분이 통째로 사라진다. → **맨 앞을 괄호로 열어** 표현식 모드로 강제할 것: `$x = (Esc("a")) + " <b>" + (Esc("c"))`
또 `"...$totalLinks개"` 는 `$totalLinks개` 를 **변수 이름 하나**로 읽는다(한글도 변수명에 쓸 수 있음). → `"...$($totalLinks)개"`

### ⚠️ 사이트맵 한글 URL (2026-09-11 수정 완료)
동네 페이지 102개가 사이트맵에 **한글 그대로** 들어가 있었다. sitemaps.org 규격은 URL-escaped 를 요구한다.
→ `gen.ps1` 의 사이트맵 생성부에서 `[Uri]::EscapeDataString($f.Name)` 을 쓴다(`%2E` 만 `.` 로 되돌림).

### 글감 선정 원칙 — 없는 수업으로 유입시키지 말 것
선생님 과목 데이터는 **국어·수학·영어·과학·사회·코딩 6개뿐**이다(`teachers-data.js` 의 `s` 필드).
- 사고력수학 · 논술 · 토론 · 한자 = **0명.** 원본 gwaoe-page 750명에도 없다. 이 키워드로 글 쓰면 들어와서 바로 이탈 → 순위 하락
- "코딩" 23명은 `gr` 자리에 **JavaScript/Python** 이 들어 있다(학년 아님). 원본은 "하우코딩(JS) 수업가능" — **유아·초등용 엔트리/스크래치가 아니다.** 초등 코딩 카드 만들지 말 것
- 지역 키워드: 방문+화상 132명 중 **유아까지 가르치는 건 8명뿐**이라 "지역+유아"는 근거 없음. 지역은 **초등**으로만, 그리고 ① 해외 도시 ② "우리 동네엔 학원이 없다" ③ 방문 겸업 시군구(3명 이상 28곳) 세 갈래에서만 자연스럽다


## 동네 페이지 (region-*.html) — 2026-09-07 신설
- `gen-region.ps1` 이 `local-places.csv` + `teachers-data.js` 를 읽어 `region-{시도}-{시군구}.html` 을 만든다
- **`local-places.csv` 형식:** `지역,동,종류,이름` (종류 = 유치원 / 어학원)
  - `지역` 은 `teachers-data.js` 의 `r`(방문지역) 값과 **글자가 똑같아야** 그 지역 선생님이 함께 실린다 (예: `서울 노원구`)
  - CSV 에 있는 지역만 페이지가 생긴다. 줄만 추가하고 아래 명령을 다시 돌리면 됨
  ```
  printf '\xEF\xBB\xBF' | cat - gen-region.ps1 > _r.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File _r.ps1 && rm _r.ps1
  ```
- `import-places.ps1` — **공공데이터 CSV → local-places.csv 변환기.** 받은 파일을 손질 없이 그대로 넣으면 됨
  ```
  printf '\xEF\xBB\xBF' | cat - import-places.ps1 > _i.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File _i.ps1 -Csv "받은파일.csv" -Type "유치원" && rm _i.ps1
  ```
  - 컬럼 이름(유치원명/학원명/사업장명, 소재지도로명주소/주소…)과 인코딩(UTF-8/CP949)을 **자동으로 찾는다**
  - 주소를 `서울특별시 노원구` → `서울 노원구`, `경기도 고양시 덕양구` → `경기 고양 덕양구` 로 바꿔 선생님 데이터의 `r` 값과 맞춘다
  - **선생님이 방문 가능한 105곳 지역만 통과**시키고 나머지는 버린다 (실을 선생님이 없는 페이지를 안 만들려고)
  - 중복은 건너뛰므로 여러 번 돌려도 안전. 어학원은 `-Type "어학원"` 으로
  - 2026-09-07 가짜 공공데이터 CSV로 동작 확인 완료 (인코딩 감지·지역 정규화·동 추출·중복 제거 전부 정상)
- 지역 후보: 방문 겸업 선생님이 있는 시군구 **105곳** (5명 이상 8곳 / 3~4명 20곳). `teachers-data.js` 의 `r` 값 분포로 확인
- ⚠️ **어학원 이름은 경쟁 업체 상호**다. 2026-09-07 사용자가 위험을 인지하고 넣기로 결정함. 네이버 저품질·분쟁 소지가 있어 문제 생기면 CSV 에서 `어학원` 줄만 지우고 다시 돌리면 즉시 걷힌다
- 유치원·어학원 목록은 공공데이터포털 [전국유치원표준데이터](https://www.data.go.kr/data/15096279/standard.do) 등에서 받아야 함. **API 는 인증키 필수라 Claude 가 직접 못 받는다** (무인증 호출 시 `-401 인증키는 필수 항목 입니다`)

## 다음에 할 후보
- 가비아 DNS: A 레코드 185.199.108.153 / .109.153 / .110.153 / .111.153 + www CNAME x26589334-cpu.github.io → GitHub Pages 에서 HTTPS 강제
- 구글 서치콘솔·네이버 서치어드바이저 등록 (meta 태그는 index.html head 에 추가)
- 실제 학부모 후기·수업 사진으로 교체 (현재 후기 3개는 예시 문구)
- 블로그(유아 한글 떼기 시기, 파닉스 시작 나이 등 SEO 글) 추가 — gwaoe-page 의 `.bpost/.article` 스타일 그대로 사용 가능
- 폼 필드명(이름/연락처/학년/분야/선생님성별/수업시간대/선생님/남길말)은 시트 헤더가 되므로 바꾸면 새 컬럼이 생김

## 사이트 안 검색 — 공용 부품 `search-kit.js`

방문자가 쓰는 검색은 이 부품을 통해 돌아간다. 하는 일은 두 가지다.

1. **띄어쓰기 무시** — "부산동래구"와 "부산 동래구"가 같은 결과. 붙여 친 말은 2글자 이상 조각으로 쪼개 찾는다. 학교 정식명칭↔약칭(중학교↔중)도 통일한다.
2. **연관 검색어** — 결과에 많이 나오는 값을 검색어에 이어 칩으로 제시. 결과 0건이면 걸리는 조각을 찾아 대안을 제시한다.

⚠️ **이 파일은 8개 저장소에 같은 내용으로 복사돼 있다**(와와·퍼펙트에듀·더나은에듀·국제학교·키즈튜터·공부의온도·H포스·픽프리).
고칠 일이 있으면 한 곳만 고치지 말고 전부 갱신할 것. 목록은 `사이트관리/사이트대장.md` 참고.
⚠️ 검색 코드보다 **먼저 로드**해야 한다(인라인 스크립트가 위에 있으면 그보다 위에).

