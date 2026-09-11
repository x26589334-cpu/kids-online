# =============================================================================
# 동네별 페이지 생성기 — region-{시도}-{시군구}.html
#
#  입력 2개
#   1) local-places.csv      지역,동,종류,이름   ← 유치원·어학원 목록 (직접 채움)
#   2) teachers-data.js      선생님 데이터        ← gen.ps1 이 만든 것
#
#  CSV 에 있는 지역만 페이지를 만든다. 지역 이름은 teachers-data.js 의
#  r(방문지역) 값과 글자가 똑같아야 그 지역 선생님이 함께 실린다. (예: "서울 노원구")
#
#  실행 (PowerShell 5.1 은 BOM 없는 .ps1 의 한글이 깨지므로 BOM 을 붙여 실행)
#    printf '\xEF\xBB\xBF' | cat - gen-region.ps1 > _r.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File _r.ps1 && rm _r.ps1
#
#  ※ 만들어진 region-*.html 은 gen.ps1 의 sitemap 자동수집에 걸리므로
#     sitemap 은 따로 손댈 필요 없다.
# =============================================================================
$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$SITE = "https://kidstutor.co.kr"
$today = (Get-Date).ToString("yyyy-MM-dd")

# ---------- 1) 장소 CSV ----------
$csvPath = Join-Path $root "local-places.csv"
if (-not (Test-Path $csvPath)) { Write-Host "local-places.csv 가 없습니다."; exit 1 }
$places = @(Import-Csv -Path $csvPath -Encoding UTF8 | Where-Object { $_.지역 -and $_.이름 })
if ($places.Count -eq 0) { Write-Host "local-places.csv 에 내용이 없습니다."; exit 1 }
Write-Host "장소 $($places.Count)건 / 지역 $(($places | Select-Object -ExpandProperty 지역 -Unique).Count)곳"

# ---------- 2) 선생님 데이터 ----------
$tjs = [IO.File]::ReadAllText((Join-Path $root "teachers-data.js"), [Text.Encoding]::UTF8)
$rx = [regex]'\{i:"(?<i>[^"]*)",n:"(?<n>[^"]*)",g:"(?<g>[^"]*)",c:"(?<c>[^"]*)",s:"(?<s>[^"]*)",gr:"(?<gr>[^"]*)",r:"(?<r>[^"]*)",sd:"(?<sd>[^"]*)",k:(?<k>\d)\}'
$teachers = @()
foreach ($m in $rx.Matches($tjs)) {
  $teachers += [pscustomobject]@{
    i=$m.Groups["i"].Value; n=$m.Groups["n"].Value; g=$m.Groups["g"].Value; c=$m.Groups["c"].Value
    s=$m.Groups["s"].Value; gr=$m.Groups["gr"].Value; r=$m.Groups["r"].Value; k=[int]$m.Groups["k"].Value
  }
}
Write-Host "선생님 $($teachers.Count)명 읽음"

# ---------- 2-2) 동네 사진 (region-photos.csv) ----------
# 위키미디어 공용에서 고른 사진. 라이선스가 CC 계열이라 저작자·라이선스 표기가 의무다.
# 표기는 figcaption 에 자동으로 들어가므로 CSV 의 작성자/라이선스 칸을 비우지 말 것.
$photos = @{}
$photoPath = Join-Path $root "region-photos.csv"
if (Test-Path $photoPath) {
  foreach ($p in @(Import-Csv -Path $photoPath -Encoding UTF8)) {
    if ($p.지역 -and $p.썸네일) { $photos[$p.지역.Trim()] = $p }
  }
}
Write-Host "동네 사진: $($photos.Count)곳"

function Esc([string]$s) { return $s.Replace("&","&amp;").Replace('"',"&quot;").Replace("<","&lt;").Replace(">","&gt;") }
function Slug([string]$s) { return ($s -replace '\s+', '-') }

$header = @'
<header>
  <div class="wrap nav">
    <a href="index.html" class="brand"><span class="logo">K</span>키즈튜터</a>
    <nav class="nav-links">
      <a href="index.html">홈</a>
      <a href="teachers.html">선생님 찾기</a>
      <a href="regions.html">우리 동네</a>
      <a href="index.html#process">수업방식</a>
      <a href="blog.html">블로그</a>
      <a href="index.html#faq">자주 묻는 질문</a>
    </nav>
    <div class="nav-cta">
      <a href="index.html#apply" class="btn btn-primary">🎁 무료체험 신청</a>
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
        <li><a href="teachers.html">선생님 찾기</a></li>
        <li><a href="regions.html">우리 동네</a></li>
        <li><a href="teachers-all.html">전체 선생님 목록</a></li>
        <li><a href="index.html#process">수업방식</a></li>
        <li><a href="blog.html">블로그</a></li>
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

$GRADS = @("linear-gradient(135deg,#ff7a1f,#ffa94d)","linear-gradient(135deg,#1fb59b,#7fe0cd)","linear-gradient(135deg,#ff5c8a,#ffa1bd)","linear-gradient(135deg,#5b8def,#9dbcff)")
$made = 0

foreach ($region in ($places | Select-Object -ExpandProperty 지역 -Unique | Sort-Object)) {
  $rows = @($places | Where-Object { $_.지역 -eq $region })
  $kinder = @($rows | Where-Object { $_.종류 -eq "유치원" })
  $academy = @($rows | Where-Object { $_.종류 -eq "어학원" })
  if ($kinder.Count -eq 0 -and $academy.Count -eq 0) { continue }

  # 지역명 쪼개기: "서울 노원구" -> 시도 "서울", 짧은 이름 "노원구"
  $parts = $region -split '\s+'
  $sido = $parts[0]
  $short = $parts[-1]

  # 이 지역 방문 가능 선생님
  $mine = @($teachers | Where-Object { $_.r -and (($_.r -split '\|') -contains $region) })

  # ---- 유치원/어학원 블록 (동별로 묶음) ----
  function PlaceBlock($list, $label) {
    if ($list.Count -eq 0) { return "" }
    $h = "      <h3>$label <span class=`"cnt`">$($list.Count)곳</span></h3>`n"
    $h += "      <div class=`"places`">`n"
    foreach ($dong in ($list | Select-Object -ExpandProperty 동 -Unique | Sort-Object)) {
      $names = @($list | Where-Object { $_.동 -eq $dong } | Select-Object -ExpandProperty 이름 | Sort-Object)
      $d = if ($dong) { $dong } else { $short }
      $h += "        <div class=`"pgroup`"><b>$(Esc $d)</b><span>" + (($names | ForEach-Object { Esc $_ }) -join " · ") + "</span></div>`n"
    }
    $h += "      </div>`n"
    return $h
  }
  $kBlock = PlaceBlock $kinder "$short 유치원"
  $aBlock = PlaceBlock $academy "$short 어학원·영어학원"

  # ---- 선생님 카드 ----
  $tBlock = ""
  if ($mine.Count -gt 0) {
    $n = 0
    foreach ($t in $mine) {
      $sub = $t.s -split ","; $grs = $t.gr -split ","
      $who = if ($t.g -eq "여") { "여선생님" } elseif ($t.g -eq "남") { "남선생님" } else { "선생님" }
      $chips = ""
      if ($t.k -eq 1) { $chips += '<span class="chip kid">유아·아동</span>' }
      for ($j = 0; $j -lt $sub.Count; $j++) {
        $g = if ($j -lt $grs.Count) { " " + $grs[$j] } else { "" }
        $chips += '<span class="chip">' + (Esc $sub[$j]) + (Esc $g) + '</span>'
      }
      $grad = $GRADS[$n % 4]; $n++
      $tBlock += "      <a class=`"tc`" href=`"teacher-$($t.i).html`"><div class=`"top`"><div class=`"ini`" style=`"background:$grad`">$($t.n.Substring(0,1))</div>"
      $tBlock += "<div><div class=`"nm`">$(Esc $t.n) 선생님</div><div class=`"sub`">$who · $(Esc $t.c)</div></div></div>"
      $tBlock += "<div class=`"chips`">$chips</div><div class=`"where`">💻 화상 수업 · $(Esc $region) 방문 가능</div></a>`n"
    }
  }

  # ---- 동네 사진 (있는 곳만) ----
  $photoBlock = ""
  if ($photos.ContainsKey($region)) {
    $ph = $photos[$region]
    $photoBlock = @"
<section style="padding:0 0 10px">
  <div class="wrap">
    <figure class="rphoto">
      <img src="$(Esc $ph.썸네일)" alt="$(Esc $region) 풍경" loading="lazy" onerror="this.parentNode.style.display='none'" />
      <figcaption>📷 $(Esc $ph.제목) — 사진 $(Esc $ph.작성자) · <a href="$(Esc $ph.출처)" target="_blank" rel="noopener nofollow">$(Esc $ph.라이선스)</a> · 위키미디어 공용</figcaption>
    </figure>
  </div>
</section>
"@
  }

  # ---- 문구 ----
  $kNames = if ($kinder.Count -gt 0) { (($kinder | Select-Object -First 4 | ForEach-Object { $_.이름 }) -join ", ") } else { "" }
  $title = "$region 유아·초등 1:1 과외 · 화상수업 | 키즈튜터"
  $desc  = "$region 유아·초등 1:1 화상과외. 한글 떼기·파닉스·연산·독서를 아이 한 명만 보고 25~50분씩 수업합니다."
  if ($kNames) { $desc += " $kNames 등 $short 유치원 학부모님이 찾으십니다." }
  $kw = "$region 유아과외, $region 초등과외, $region 한글과외, $region 파닉스, $region 화상과외, $short 유아과외, $short 초등 과외, $sido 유아 과외"
  if ($kinder.Count -gt 0) { $kw += ", " + (($kinder | Select-Object -First 8 | ForEach-Object { $_.이름 }) -join ", ") }
  if ($academy.Count -gt 0) { $kw += ", " + (($academy | Select-Object -First 5 | ForEach-Object { $_.이름 }) -join ", ") }

  $file = "region-" + (Slug $region) + ".html"
  $url = "$SITE/$file"

  $tSection = ""
  if ($mine.Count -gt 0) {
    $tSection = @"
<section>
  <div class="wrap center">
    <span class="eyebrow">$short 선생님</span>
    <h2 class="title">$short 방문도 가능한 선생님 $($mine.Count)분</h2>
    <p class="lead">기본은 화상 수업이라 전국 어디서나 되고, 아래 선생님들은 $region 방문 수업도 가능합니다.</p>
  </div>
  <div class="wrap tgrid" style="margin-top:34px">
$tBlock  </div>
  <div class="center" style="margin-top:30px">
    <a href="teachers.html" class="btn btn-ghost">선생님 전체 보기</a>
  </div>
</section>
"@
  }

  $page = @"
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>$(Esc $title)</title>
<meta name="description" content="$(Esc $desc)" />
<meta name="keywords" content="$(Esc $kw)" />
<link rel="canonical" href="$url" />
<meta property="og:type" content="article" />
<meta property="og:site_name" content="키즈튜터" />
<meta property="og:title" content="$(Esc $title)" />
<meta property="og:description" content="$(Esc $desc)" />
<meta property="og:url" content="$url" />
<meta property="og:image" content="$SITE/og-image.png" />
<meta property="og:locale" content="ko_KR" />
<meta name="robots" content="index,follow" />
<meta name="theme-color" content="#ff7a1f" />
<link rel="icon" href="favicon.svg" type="image/svg+xml" />
<link rel="apple-touch-icon" href="apple-touch-icon.png" />
<link rel="preconnect" href="https://fastly.jsdelivr.net" crossorigin />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fastly.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Jua&display=swap" />
<link rel="stylesheet" href="style.css?v=8" />
</head>
<body>
$header
<section class="page-hero">
  <div class="wrap">
    <div class="crumb"><a href="index.html">홈</a> › <a href="teachers.html">선생님 찾기</a> › $(Esc $region)</div>
    <h1>$(Esc $region) 유아·초등<br>1:1 화상과외</h1>
    <p>한글 떼기, 파닉스, 연산, 독서, 초등 입학 준비까지. 유아·아동을 오래 가르쳐 온 선생님이 아이 한 명만 보고 25~50분씩 수업합니다. 집에서 태블릿 하나로 시작하세요.</p>
  </div>
</section>
$photoBlock
$tSection
<section style="background:var(--bg-soft)">
  <div class="wrap">
    <div class="lesson">
      <h3>$(Esc $short) 우리 동네 유치원·학원</h3>
      <div class="sub">$(Esc $short)에서 유아·초등 자녀를 키우는 학부모님들이 많이 찾는 곳들입니다. 아이가 다니는 곳 이름을 알려주시면 수업 시간대를 맞춰 드려요.</div>
$kBlock$aBlock    </div>
  </div>
</section>

<section>
  <div class="wrap center">
    <h2 class="title">$(Esc $short)에서 화상수업, 이런 점이 좋아요</h2>
  </div>
  <div class="wrap feat">
    <div class="item reveal"><div class="ico">🚗</div><h4>학원 라이드가 없습니다</h4><p>하원 후 바로 집에서 수업합니다. 왕복 이동 시간이 통째로 사라지고, 아이도 덜 지칩니다.</p></div>
    <div class="item reveal"><div class="ico">👶</div><h4>유아도 됩니다</h4><p>5~7세는 25~30분으로 짧게, 활동을 5~7분마다 바꿔 진행합니다. 처음 2주는 부모님이 옆에 앉아 주셔도 좋아요.</p></div>
    <div class="item reveal"><div class="ico">👀</div><h4>부모님이 다 보실 수 있습니다</h4><p>수업을 옆에서 참관하실 수 있고, 매주 무엇을 했는지 한 줄 리포트로 받아보십니다.</p></div>
  </div>
  <div class="center" style="margin-top:34px">
    <a href="index.html#apply" class="btn btn-primary">🎁 무료 20분 체험 신청</a>
  </div>
</section>
$footer
<div class="float-cta">
  <a href="index.html#apply" class="btn btn-primary">🎁 무료 체험 신청</a>
</div>
<script src="script.js"></script>
</body>
</html>
"@

  [IO.File]::WriteAllText((Join-Path $root $file), $page, $utf8)
  Write-Host ("  " + $file + " — 유치원 " + $kinder.Count + " / 어학원 " + $academy.Count + " / 선생님 " + $mine.Count)
  $made++
}
Write-Host "동네 페이지 $made 개 생성 완료"

# ---------- 동네 목록 페이지 (regions.html) ----------
# 만들어진 동네 페이지로 들어가는 '문'. 이게 없으면 102장이 sitemap 에만 있고
# 사이트 안에서 이동할 길이 없어 검색엔진이 중요하지 않은 페이지로 본다.
# 지역이 늘면 이 스크립트를 다시 돌리기만 하면 목록도 같이 갱신된다.
$idx = @()
foreach ($region in ($places | Select-Object -ExpandProperty 지역 -Unique | Sort-Object)) {
  $rows = @($places | Where-Object { $_.지역 -eq $region })
  $kc = @($rows | Where-Object { $_.종류 -eq "유치원" }).Count
  $ac = @($rows | Where-Object { $_.종류 -eq "어학원" }).Count
  if ($kc -eq 0 -and $ac -eq 0) { continue }
  $tc = @($teachers | Where-Object { $_.r -and (($_.r -split '\|') -contains $region) }).Count
  $parts = $region -split '\s+'
  $idx += [pscustomobject]@{
    region = $region; sido = $parts[0]; short = ($parts[1..($parts.Count-1)] -join " ")
    file = "region-" + (Slug $region) + ".html"; k = $kc; a = $ac; t = $tc
  }
}

$sidoOrder = @("서울","경기","인천","부산","대구","광주","대전","울산","세종","강원","충북","충남","전북","전남","경북","경남","제주")
$body = ""
foreach ($sd in $sidoOrder) {
  $group = @($idx | Where-Object { $_.sido -eq $sd } | Sort-Object short)
  if ($group.Count -eq 0) { continue }
  $body += "  <div class=`"wrap`" style=`"margin-top:26px`">`n"
  $body += "    <h3 class=`"sido-head`">$sd <span class=`"cnt`">$($group.Count)곳</span></h3>`n"
  $body += "    <div class=`"rgrid`">`n"
  foreach ($g in $group) {
    $body += "      <a class=`"rcard`" href=`"$($g.file)`"><b>$(Esc $g.short)</b><span>유치원 $($g.k) · 어학원 $($g.a)</span></a>`n"
  }
  $body += "    </div>`n  </div>`n"
}

$totK = ($idx | Measure-Object -Property k -Sum).Sum
$totA = ($idx | Measure-Object -Property a -Sum).Sum
$sidoNames = (($sidoOrder | Where-Object { @($idx | Where-Object { $_.sido -eq $_ }).Count -ge 0 }) -join " ")

$rTitle = "우리 동네 유아·초등 1:1 과외 · 전국 $($idx.Count)곳 | 키즈튜터"
$rDesc  = "전국 $($idx.Count)개 동네의 유치원 $totK 곳과 영어학원 $totA 곳, 그리고 그 지역에 방문도 가능한 선생님을 함께 정리했습니다. 화상 수업은 전국·해외 어디서나 가능합니다."

$rPage = @"
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>$(Esc $rTitle)</title>
<meta name="description" content="$(Esc $rDesc)" />
<meta name="keywords" content="동네 유아과외, 지역별 초등과외, 우리 동네 유치원, 동네 영어학원, 유아 화상과외, 초등 화상과외" />
<link rel="canonical" href="$SITE/regions.html" />
<meta property="og:type" content="website" />
<meta property="og:site_name" content="키즈튜터" />
<meta property="og:title" content="$(Esc $rTitle)" />
<meta property="og:description" content="$(Esc $rDesc)" />
<meta property="og:url" content="$SITE/regions.html" />
<meta property="og:image" content="$SITE/og-image.png" />
<meta property="og:locale" content="ko_KR" />
<meta name="robots" content="index,follow" />
<meta name="theme-color" content="#ff7a1f" />
<link rel="icon" href="favicon.svg" type="image/svg+xml" />
<link rel="apple-touch-icon" href="apple-touch-icon.png" />
<link rel="preconnect" href="https://fastly.jsdelivr.net" crossorigin />
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet" href="https://fastly.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css" />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Jua&display=swap" />
<link rel="stylesheet" href="style.css?v=8" />
</head>
<body>
$header
<section class="page-hero">
  <div class="wrap">
    <div class="crumb"><a href="index.html">홈</a> › 우리 동네</div>
    <h1>우리 동네<br>유아·초등 1:1 과외</h1>
    <p>전국 $($idx.Count)개 동네의 유치원 $totK 곳과 영어학원 $totA 곳을 동별로 정리했습니다. 수업은 화상이라 전국 어디서나 되고, 동네에 따라 방문도 가능한 선생님이 있습니다.</p>
  </div>
</section>

<section>
  <div class="wrap center">
    <span class="eyebrow">지역 선택</span>
    <h2 class="title">사시는 동네를 골라 주세요</h2>
    <p class="lead">아이가 다니는 유치원이나 학원 이름을 상담에서 말씀해 주시면 수업 시간대를 그에 맞춰 잡아 드려요.</p>
  </div>
$body</section>

<section style="background:var(--bg-soft)">
  <div class="wrap center">
    <h2 class="title">우리 동네가 목록에 없어도 됩니다</h2>
    <p class="lead center">화상 수업이라 인터넷만 되면 전국·해외 어디서나 가능합니다. 목록은 방문도 가능한 선생님이 있는 동네만 모아 둔 것이에요.</p>
    <div class="hero-cta" style="justify-content:center;margin-top:24px">
      <a href="index.html#apply" class="btn btn-primary">🎁 무료 20분 체험 신청</a>
      <a href="teachers.html" class="btn btn-ghost">선생님 전체 보기</a>
    </div>
  </div>
</section>
$footer
<div class="float-cta">
  <a href="index.html#apply" class="btn btn-primary">🎁 무료 체험 신청</a>
</div>
<script src="script.js"></script>
</body>
</html>
"@
[IO.File]::WriteAllText((Join-Path $root "regions.html"), $rPage, $utf8)
Write-Host "regions.html: $($idx.Count)개 동네 (유치원 $totK · 어학원 $totA)"
