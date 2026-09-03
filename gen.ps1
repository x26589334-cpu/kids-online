# 키즈튜터 — 선생님 데이터/개별 페이지/사이트맵 생성기
# 원본: ../gwaoe-page/teachers-data.js, teachers-search.js, teacher-{id}.html
# 선택 기준: 화상 가능(화상 / 방문+화상) AND (유아·아동 코치 k=1 OR 어떤 과목이든 유아·초등(초1~6)부터 지도)
# 실행: powershell -NoProfile -ExecutionPolicy Bypass -File gen_bom.ps1   (UTF-8 BOM 필수)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$utf8 = New-Object System.Text.UTF8Encoding($false)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path (Split-Path -Parent $root) "gwaoe-page"
$SITE = "https://kidstutor.co.kr"
$today = (Get-Date).ToString("yyyy-MM-dd")

# ---------- 1) 선생님 선택 ----------
$data = [IO.File]::ReadAllText((Join-Path $src "teachers-data.js"), [Text.Encoding]::UTF8)
$rx = [regex]'\{i:"(?<i>[^"]+)",n:"(?<n>[^"]*)",g:"(?<g>[^"]*)",c:"(?<c>[^"]*)",s:"(?<s>[^"]*)",gr:"(?<gr>[^"]*)",r:"(?<r>[^"]*)",sd:"(?<sd>[^"]*)",k:(?<k>\d)\}'
$all = @()
foreach ($m in $rx.Matches($data)) {
  $t = [ordered]@{}
  foreach ($k in "i","n","g","c","s","gr","r","sd") { $t[$k] = $m.Groups[$k].Value }
  $t["k"] = [int]$m.Groups["k"].Value
  $all += [pscustomobject]$t
}
$sel = @($all | Where-Object {
  $_.c -match "화상" -and ( $_.k -eq 1 -or (($_.gr -split ",") | Where-Object { $_ -match "^(유아|초)" }) )
})
# 유아·아동 코치 먼저, 그 다음 원래 순서
$sel = @($sel | Where-Object { $_.k -eq 1 }) + @($sel | Where-Object { $_.k -ne 1 })
Write-Host "선택된 선생님: $($sel.Count)명 (유아·아동 코치 $(@($sel | ? { $_.k -eq 1 }).Count)명)"

# ---------- 2) teachers-data.js ----------
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("/* 키즈튜터 선생님 목록 데이터 (자동 생성 · gen.ps1)")
[void]$sb.AppendLine("   i=id, n=이름(마스킹), g=성별, c=수업형태, s=과목, gr=학년, r=방문지역, sd=시도, k=유아·아동 코치")
[void]$sb.AppendLine("   원본: perfectedu.co.kr(gwaoe-page) 코치 데이터 중 화상 가능 + 유아·초등 지도 선생님만 */")
[void]$sb.AppendLine("window.TEACHERS=[")
$lines = @()
foreach ($t in $sel) {
  $lines += ('{i:"' + $t.i + '",n:"' + $t.n + '",g:"' + $t.g + '",c:"' + $t.c + '",s:"' + $t.s + '",gr:"' + $t.gr + '",r:"' + $t.r + '",sd:"' + $t.sd + '",k:' + $t.k + '}')
}
[void]$sb.Append(($lines -join ",`n"))
[void]$sb.AppendLine("`n];")
[IO.File]::WriteAllText((Join-Path $root "teachers-data.js"), $sb.ToString(), $utf8)

# ---------- 3) teachers-search.js (검색 색인 부분집합) ----------
$search = [IO.File]::ReadAllText((Join-Path $src "teachers-search.js"), [Text.Encoding]::UTF8)
$srx = [regex]'"(?<id>[A-Z0-9]{4,12})":"(?<txt>(?:[^"\\]|\\.)*)"'
$idx = @{}
foreach ($m in $srx.Matches($search)) { $idx[$m.Groups["id"].Value] = $m.Groups["txt"].Value }
$ids = @{}; foreach ($t in $sel) { $ids[$t.i] = $true }
$parts = @()
foreach ($t in $sel) { if ($idx.ContainsKey($t.i)) { $parts += ('"' + $t.i + '":"' + $idx[$t.i] + '"') } }
$s2 = "/* 키즈튜터 선생님 검색 색인 (자동 생성 · gen.ps1)`n   { 선생님id: '소개·경력 본문' } — 소문자. teachers.html 에서 defer 로 로드 */`nwindow.TSEARCH={" + ($parts -join ",") + "};`nif(window.__tRefresh)window.__tRefresh();`n"
[IO.File]::WriteAllText((Join-Path $root "teachers-search.js"), $s2, $utf8)
Write-Host "검색 색인: $($parts.Count)건"

# ---------- 4) 선생님 개별 페이지 ----------
$GRADS = @("linear-gradient(135deg,#ff7a1f,#ffa94d)","linear-gradient(135deg,#1fb59b,#7fe0cd)","linear-gradient(135deg,#ff5c8a,#ffa1bd)","linear-gradient(135deg,#5b8def,#9dbcff)")
$rxChips = [regex]'(?s)<div class="chips">(.*?)</div>'
$rxSec   = [regex]'(?s)<div class="tsec">\s*<h3>(.*?)</h3>(.*?)\n    </div>'
$rxLi    = [regex]'(?s)<li>(.*?)</li>'

function Esc([string]$s) { return $s.Replace("&","&amp;").Replace('"',"&quot;").Replace("<","&lt;").Replace(">","&gt;") }

$header = @'
<header>
  <div class="wrap nav">
    <a href="index.html" class="brand"><span class="logo">K</span>키즈튜터</a>
    <nav class="nav-links">
      <a href="index.html">홈</a>
      <a href="index.html#ages">연령별 수업</a>
      <a href="index.html#courses">프로그램</a>
      <a href="teachers.html" class="active">선생님 찾기</a>
      <a href="process.html">수업방식</a>
      <a href="index.html#reviews">학부모 후기</a>
      <a href="index.html#faq">자주 묻는 질문</a>
    </nav>
    <div class="nav-cta">
      <a href="#tform" class="btn btn-primary">🎁 무료체험 신청</a>
    </div>
  </div>
</header>
'@
$footer = @'
<footer>
  <div class="wrap foot-grid">
    <div>
      <div class="brand"><span class="logo">K</span>키즈튜터</div>
      <p>5세부터 초등 6학년까지, 유아·아동 전문 선생님과 하는 1:1 화상 수업. 티칭코칭(perfectedu.co.kr)의 유아·초등 전문 서비스입니다.</p>
    </div>
    <div>
      <h5>바로가기</h5>
      <ul>
        <li><a href="index.html#ages">연령별 수업</a></li>
        <li><a href="index.html#courses">프로그램</a></li>
        <li><a href="teachers.html">선생님 찾기</a></li>
        <li><a href="process.html">수업방식</a></li>
        <li><a href="https://perfectedu.co.kr/" rel="noopener">초·중·고 과외는 티칭코칭</a></li>
      </ul>
    </div>
    <div>
      <h5>문의</h5>
      <ul>
        <li><a href="tel:01068321994">전화: 010-6832-1994</a></li>
        <li><a href="index.html#apply">무료 체험 신청</a></li>
        <li><a href="index.html">운영시간: 09:00 – 21:00</a></li>
      </ul>
    </div>
  </div>
  <div class="wrap copy-bar">
    <span>© 2026 키즈튜터. All rights reserved.</span>
    <span>이용약관 · 개인정보처리방침</span>
  </div>
</footer>
'@

$made = 0; $missing = @()
$n = 0
foreach ($t in $sel) {
  $srcFile = Join-Path $src ("teacher-" + $t.i + ".html")
  if (-not (Test-Path $srcFile)) { $missing += $t.i; continue }
  $html = [IO.File]::ReadAllText($srcFile, [Text.Encoding]::UTF8)

  # 소개/지도과목/경력 섹션 추출
  $secs = @{}
  foreach ($m in $rxSec.Matches($html)) { $secs[$m.Groups[1].Value.Trim()] = $m.Groups[2].Value }
  # 원본 섹션 제목이 다양(학력·경력/수업 방식/강점 …)하므로 "수업 형태"·"방문 가능 지역"만 빼고 순서대로 모두 가져온다
  $keep = @()
  foreach ($m in $rxSec.Matches($html)) { $h = $m.Groups[1].Value.Trim(); if ($h -ne "수업 형태" -and $h -ne "방문 가능 지역") { $body = [regex]::Replace($m.Groups[2].Value, "s*<li>s*최종s*수정[^<]*</li>", ""); if ($body -match "<li>|<p") { $keep += ,@($h, $body) } } }

  $subs = $t.s -split ","; $grs = $t.gr -split ","
  $subjLabel = ($subs -join "·")
  $who = if ($t.g -eq "여") { "여선생님" } elseif ($t.g -eq "남") { "남선생님" } else { "선생님" }
  $starts = @(); foreach ($gp in ($t.gr -split ",")) { if ($gp -match "^유아") { $starts += 0 } elseif ($gp -match "^초([1-6])") { $starts += [int]$Matches[1] } }
  $minS = if ($starts.Count) { ($starts | Measure-Object -Minimum).Minimum } else { 1 }
  $lowest = if ($minS -eq 0) { "유아" } else { "초등 ${minS}학년" }
  $kidTag = if ($t.k -eq 1) { "유아·아동 코칭 경력" } else { "${lowest}부터 지도" }

  # 칩
  $chips = ""
  if ($t.k -eq 1) { $chips += '<span class="chip kid">유아·아동</span>' }
  if ($t.g) { $chips += '<span class="chip">' + $who + '</span>' }
  $chips += '<span class="chip on">' + $t.c + '</span>'
  for ($j = 0; $j -lt $subs.Count; $j++) {
    $g = if ($j -lt $grs.Count) { " " + $grs[$j] } else { "" }
    $chips += '<span class="chip">' + $subs[$j] + $g + '</span>'
  }

  # 수업 형태 문구
  $modeText = if ($t.c -eq "방문+화상") {
    "전국·해외 어디서나 가능한 1:1 화상 수업을 기본으로 하며, " + (($t.r -split "\|") -join ", ") + " 지역은 방문 수업도 가능합니다."
  } else {
    "이동 시간 없이 화면으로 진행하는 실시간 1:1 화상 수업입니다. 전국·해외 어디서나 가능합니다."
  }

  $title = $t.n + " 선생님 · " + $subjLabel + " 유아·초등 화상과외 · 키즈튜터"
  $desc  = $lowest + "부터 지도하는 " + $subjLabel + " 1:1 화상 수업 " + $who + ". " + $kidTag + ". " + $t.c + " 수업. 무료 20분 체험으로 아이 반응을 먼저 확인하세요."
  $kw    = ($subs | ForEach-Object { "유아 " + $_ + " 화상과외, 초등 " + $_ + " 과외" }) -join ", "
  $url   = "$SITE/teacher-" + $t.i + ".html"
  $grad  = $GRADS[$n % 4]; $n++

  $secHtml = ""
  foreach ($kv in $keep) { $secHtml += "    <div class=`"tsec`">`n      <h3>" + $kv[0] + "</h3>" + $kv[1] + "`n    </div>`n" }

  $page = @"
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>$(Esc $title)</title>
<meta name="description" content="$(Esc $desc)" />
<meta name="keywords" content="$(Esc $kw), 아동 화상 수업, 키즈튜터" />
<link rel="canonical" href="$url" />
<meta name="robots" content="index,follow" />
<meta name="theme-color" content="#ff7a1f" />
<meta property="og:type" content="profile" />
<meta property="og:site_name" content="키즈튜터" />
<meta property="og:title" content="$(Esc $title)" />
<meta property="og:description" content="$(Esc $desc)" />
<meta property="og:url" content="$url" />
<meta property="og:image" content="$SITE/og-image.png" />
<meta property="og:locale" content="ko_KR" />
<meta name="twitter:card" content="summary_large_image" />
<link rel="icon" href="favicon.svg" type="image/svg+xml" />
<link rel="apple-touch-icon" href="apple-touch-icon.png" />
<link rel="preconnect" href="https://fastly.jsdelivr.net" crossorigin />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fastly.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Jua&display=swap" />
<link rel="stylesheet" href="style.css?v=1" />
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "$($t.n) 선생님",
  "jobTitle": "유아·초등 화상 과외 선생님",
  "url": "$url",
  "knowsAbout": [$(($subs | ForEach-Object { '"' + $_ + '"' }) -join ",")],
  "worksFor": { "@type": "EducationalOrganization", "name": "키즈튜터", "url": "$SITE/" }
}
</script>
</head>
<body>
$header
<section class="page-hero">
  <div class="wrap">
    <div class="crumb"><a href="index.html">홈</a> › <a href="teachers.html">선생님 찾기</a> › $($t.n) 선생님</div>
    <h1>$($t.n) 선생님</h1>
    <p>$subjLabel · $($t.c) 수업 · $kidTag</p>
  </div>
</section>
<section>
  <div class="wrap tprofile">
    <div class="tcard">
      <div class="ini" style="background:$grad">$($t.n.Substring(0,1))</div>
      <div class="meta">
        <h2>$($t.n) 선생님</h2>
        <div class="chips">$chips</div>
      </div>
      <a href="#tform" class="btn btn-primary tcta">🎁 이 선생님과 무료 체험</a>
    </div>
    <div class="tsec">
      <h3>이런 아이에게 맞아요</h3>
      <p class="tdesc">${lowest}부터 $subjLabel 수업이 가능한 선생님입니다. $(if ($t.k -eq 1) { "유아·아동 코칭 경력이 있어 5~7세 아이의 첫 수업, 낯가림이 있는 아이에게 특히 잘 맞습니다." } else { "초등 지도 경험이 있어 학교 진도 다지기부터 교과 심화까지 잘 맞습니다." }) 수업은 아이 집중 시간에 맞춰 25~50분으로 진행합니다.</p>
    </div>
$secHtml    <div class="tsec">
      <h3>수업 형태</h3>
      <p class="tdesc">$modeText</p>
    </div>
    <div class="tform" id="tform">
      <h3>🎁 $($t.n) 선생님과 무료 20분 체험 수업</h3>
      <p class="lead">아이 나이와 연락처만 남겨 주세요. 이 선생님의 가능 시간을 확인해 24시간 안에 연락드릴게요.</p>
      <form id="teacherForm" novalidate>
        <input type="hidden" id="f_teacher" value="$($t.n) ($($t.i))" />
        <div class="two">
          <div class="field"><label for="f_name">보호자 이름</label><input id="f_name" type="text" placeholder="홍길동" required /></div>
          <div class="field"><label for="f_phone">연락처</label><input id="f_phone" type="tel" placeholder="010-0000-0000" required /></div>
        </div>
        <div class="field"><label for="f_age">아이 나이 · 학년</label>
          <select id="f_age" required><option value="">선택</option><option>5세</option><option>6세</option><option>7세</option><option>초등 1학년</option><option>초등 2학년</option><option>초등 3학년</option><option>기타</option></select>
        </div>
        <div class="field"><label for="f_memo">아이에 대해 알려주세요 (선택)</label><textarea id="f_memo" rows="3" placeholder="예) 한글은 읽는데 쓰기를 싫어해요 / 평일 저녁 7시 이후 / 낯을 가려요"></textarea></div>
        <button type="submit" class="btn btn-primary">이 선생님과 무료 체험 신청</button>
        <div class="form-note">신청 시 개인정보 수집·이용에 동의하는 것으로 간주됩니다.</div>
        <div class="ok-msg" id="tfOk">✅ 신청이 접수되었어요! 24시간 안에 연락드릴게요.</div>
      </form>
    </div>
    <div class="tback"><a href="teachers.html">← 유아·초등 선생님 전체 보기</a></div>
  </div>
</section>
<section style="background:var(--bg-soft)">
  <div class="wrap center">
    <h2 class="title">전화가 더 편하시면</h2>
    <p class="lead center">아이 나이와 필요한 한 가지만 말씀해 주시면 바로 안내해 드려요.</p>
    <div class="hero-cta" style="justify-content:center;margin-top:24px">
      <a href="tel:01068321994" class="btn btn-primary">📞 010-6832-1994 상담신청</a>
      <a href="process.html" class="btn btn-ghost">수업방식 보기</a>
    </div>
  </div>
</section>
$footer
<div class="float-cta">
  <a href="#tform" class="btn btn-primary">🎁 무료 체험 신청</a>
</div>
<script src="script.js"></script>
<script src="form.js"></script>
</body>
</html>
"@
  [IO.File]::WriteAllText((Join-Path $root ("teacher-" + $t.i + ".html")), $page, $utf8)
  $made++
}
Write-Host "선생님 페이지 생성: ${made}개"

# ---------- 5) sitemap.xml ----------
$sm = New-Object System.Text.StringBuilder
[void]$sm.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sm.AppendLine('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
[void]$sm.AppendLine("  <url><loc>$SITE/</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>1.0</priority></url>")
[void]$sm.AppendLine("  <url><loc>$SITE/teachers.html</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.9</priority></url>")
[void]$sm.AppendLine("  <url><loc>$SITE/process.html</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.8</priority></url>")
foreach ($t in $sel) {
  if ($missing -contains $t.i) { continue }
  [void]$sm.AppendLine("  <url><loc>$SITE/teacher-$($t.i).html</loc><lastmod>$today</lastmod><changefreq>monthly</changefreq><priority>0.6</priority></url>")
}
[void]$sm.AppendLine('</urlset>')
[IO.File]::WriteAllText((Join-Path $root "sitemap.xml"), $sm.ToString(), $utf8)
Write-Host "sitemap.xml: $($made + 3) URL"
