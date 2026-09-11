# build_rss.ps1 — 키즈튜터 블로그 RSS 생성기
#   blog.html 의 글 카드(날짜·분류·제목·요약·링크)를 읽어 rss.xml 을 만든다 (최신 100건).
#   새 글을 blog.html 에 추가한 뒤 실행하고 rss.xml 을 함께 커밋한다. 재실행 안전.
#   실행: powershell -NoProfile -ExecutionPolicy Bypass -File tools\build_rss.ps1
#   ※ 이 파일은 UTF-8 BOM 으로 저장돼 있어야 한다 (PowerShell 5.1 은 .ps1 을 ANSI 로 읽는다)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$BASE = 'https://kidstutor.co.kr'
$MAX  = 100
$enc  = New-Object System.Text.UTF8Encoding($false)
function X($s) { return ("$s" -replace '&(?!amp;|lt;|gt;|quot;|#)', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;') }
function Strip($s) { return ([regex]::Replace("$s", '<[^>]+>', '') -replace '\s+', ' ').Trim() }

$html = [IO.File]::ReadAllText((Join-Path $root 'blog.html'), [Text.Encoding]::UTF8)
$listStart = $html.IndexOf('id="blogList"')
if ($listStart -lt 0) { throw 'blog.html 에서 blogList 를 찾지 못했습니다.' }
$list = $html.Substring($listStart)

$items = New-Object System.Collections.ArrayList
foreach ($m in [regex]::Matches($list, '<article class="bpost[^"]*">(.*?)</article>', 'Singleline')) {
  $card = $m.Groups[1].Value
  $date = [regex]::Match($card, '<span class="date">(\d{4})\.(\d{2})\.(\d{2})</span>')
  $link = [regex]::Match($card, '<h3><a href="([^"]+)">(.*?)</a></h3>', 'Singleline')
  if (-not $date.Success -or -not $link.Success) { continue }
  $cat  = Strip ([regex]::Match($card, '<span class="cat">(.*?)</span>', 'Singleline').Groups[1].Value)
  $desc = Strip ([regex]::Match($card, '</h3>\s*<p>(.*?)</p>', 'Singleline').Groups[1].Value)
  $dt = Get-Date -Year ([int]$date.Groups[1].Value) -Month ([int]$date.Groups[2].Value) -Day ([int]$date.Groups[3].Value) -Hour 10 -Minute 0 -Second 0
  [void]$items.Add([pscustomobject]@{ url = "$BASE/$($link.Groups[1].Value)"; title = (Strip $link.Groups[2].Value); desc = $desc; cat = $cat; date = $dt })
}
$items = $items | Sort-Object date -Descending | Select-Object -First $MAX
if (-not $items) { throw 'blog.html 에서 글 카드를 하나도 읽지 못했습니다.' }

$ci = [Globalization.CultureInfo]::InvariantCulture
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$sb.AppendLine('<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom"><channel>')
[void]$sb.AppendLine('<title>키즈튜터 — 유아·초등 화상과외 이야기</title>')
[void]$sb.AppendLine("<link>$BASE/blog.html</link>")
[void]$sb.AppendLine('<description>한글떼기·숫자놀이·초등 학습 고민·해외 거주 가정을 위한 키즈튜터 블로그</description>')
[void]$sb.AppendLine('<language>ko</language>')
[void]$sb.AppendLine("<atom:link href=`"$BASE/rss.xml`" rel=`"self`" type=`"application/rss+xml`" />")
[void]$sb.AppendLine("<lastBuildDate>$((Get-Date).ToString('ddd, dd MMM yyyy HH:mm:ss', $ci)) +0900</lastBuildDate>")
foreach ($it in $items) {
  [void]$sb.AppendLine('<item>')
  [void]$sb.AppendLine("<title>$(X $it.title)</title>")
  [void]$sb.AppendLine("<link>$(X $it.url)</link>")
  [void]$sb.AppendLine("<guid isPermaLink=`"true`">$(X $it.url)</guid>")
  if ($it.cat)  { [void]$sb.AppendLine("<category>$(X $it.cat)</category>") }
  [void]$sb.AppendLine("<description>$(X $it.desc)</description>")
  [void]$sb.AppendLine("<pubDate>$($it.date.ToString('ddd, dd MMM yyyy HH:mm:ss', $ci)) +0900</pubDate>")
  [void]$sb.AppendLine('</item>')
}
[void]$sb.AppendLine('</channel></rss>')
[IO.File]::WriteAllText((Join-Path $root 'rss.xml'), $sb.ToString(), $enc)
Write-Host "rss.xml 생성: $(@($items).Count)건 (최신: $($items[0].title))"
