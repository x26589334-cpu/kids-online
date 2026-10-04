# apple-touch-icon.png (180x180) 생성 — System.Drawing
#
# ⚠️ og-image.png 는 더 이상 이 스크립트가 만들지 않는다 (2026-10-04).
#    사용자가 직접 만든 그림(아이 사진이 들어간 썸네일)으로 바꿨고, 그 파일이 저장소의 og-image.png 다.
#    아래 OG 생성 코드는 참고용으로 남겨뒀지만 $MAKE_OG 가 $false 라 실행되지 않는다.
#    다시 코드로 그리고 싶으면 $MAKE_OG 를 $true 로 바꿀 것 — 사용자 그림을 덮어쓴다.
$MAKE_OG = $false

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function C([string]$hex) { return [System.Drawing.ColorTranslator]::FromHtml($hex) }
function B([string]$hex) { return [System.Drawing.SolidBrush]::new((C $hex)) }
function BA([int]$a, [string]$hex) { $c = C $hex; return [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($a, $c.R, $c.G, $c.B)) }

function RR([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
  $p = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $p.AddArc($x, $y, $r*2, $r*2, 180, 90)
  $p.AddArc($x+$w-$r*2, $y, $r*2, $r*2, 270, 90)
  $p.AddArc($x+$w-$r*2, $y+$h-$r*2, $r*2, $r*2, 0, 90)
  $p.AddArc($x, $y+$h-$r*2, $r*2, $r*2, 90, 90)
  $p.CloseFigure(); return $p
}

# 쓸 수 있는 가장 굵은 한글 폰트 고르기
$famName = "Malgun Gothic"
foreach ($n in @("Noto Sans KR Black", "NanumGothicExtraBold", "HYGothic-Extra", "Malgun Gothic")) {
  try { $t = [System.Drawing.FontFamily]::new($n); $t.Dispose(); $famName = $n; break } catch {}
}
$FAM = [System.Drawing.FontFamily]::new($famName)
$FSTYLE = 0
if ($FAM.IsStyleAvailable([System.Drawing.FontStyle]::Bold)) { $FSTYLE = 1 }
$TYPO = [System.Drawing.StringFormat]::GenericTypographic

# 스티커 글씨: 그림자 → 흰 테두리 → 진한 윤곽 → 그라데이션 채움
function Sticker {
  param($g, [string]$text, [single]$em, [single]$x, [single]$y,
        [string]$c1, [string]$c2, [single]$halo = 30, [single]$ink = 15)
  $p = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $p.AddString($text, $FAM, $FSTYLE, $em, [System.Drawing.PointF]::new($x, $y), $TYPO)
  $sh = $p.Clone()
  $m = [System.Drawing.Drawing2D.Matrix]::new(); $m.Translate(8, 11); $sh.Transform($m)
  $g.FillPath((BA 40 "#8a4a10"), $sh)
  $pw = [System.Drawing.Pen]::new([System.Drawing.Color]::White, $halo); $pw.LineJoin = "Round"; $g.DrawPath($pw, $p)
  $pk = [System.Drawing.Pen]::new((C "#222b40"), $ink); $pk.LineJoin = "Round"; $g.DrawPath($pk, $p)
  $b = $p.GetBounds()
  $grad = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.PointF]::new($b.X, $b.Y), [System.Drawing.PointF]::new($b.X, $b.Y + $b.Height), (C $c1), (C $c2))
  $g.FillPath($grad, $p)
  return $b
}

# 테두리 없는 보통 글씨
function Txt {
  param($g, [string]$text, [single]$em, [single]$x, [single]$y, [string]$col)
  $p = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $p.AddString($text, $FAM, $FSTYLE, $em, [System.Drawing.PointF]::new($x, $y), $TYPO)
  $g.FillPath((B $col), $p)
  return $p.GetBounds()
}

# 반짝이(4각 별)
function Spark {
  param($g, [single]$cx, [single]$cy, [single]$r, [string]$col)
  $p = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $k = $r * 0.26
  $p.AddPolygon(@(
    [System.Drawing.PointF]::new($cx, $cy-$r), [System.Drawing.PointF]::new($cx+$k, $cy-$k),
    [System.Drawing.PointF]::new($cx+$r, $cy), [System.Drawing.PointF]::new($cx+$k, $cy+$k),
    [System.Drawing.PointF]::new($cx, $cy+$r), [System.Drawing.PointF]::new($cx-$k, $cy+$k),
    [System.Drawing.PointF]::new($cx-$r, $cy), [System.Drawing.PointF]::new($cx-$k, $cy-$k)))
  $g.FillPath((B $col), $p)
}

# 마스코트 키투 — favicon.svg 와 같은 도형 (그 좌표계 그대로, 박스 중심 70,72)
function Kitu {
  param($g, [single]$cx, [single]$cy, [single]$s)
  $k = $g.Save()
  $g.TranslateTransform($cx, $cy); $g.ScaleTransform($s, $s); $g.TranslateTransform(-70, -72)
  $kpen = [System.Drawing.Pen]::new((C "#4a3524"), 5)
  $kpen.StartCap = "Round"; $kpen.EndCap = "Round"; $kpen.LineJoin = "Round"
  $g.DrawBezier($kpen, 68, 30, 64, 12, 80, 8, 84, 20)                                      # 더듬이
  $g.FillEllipse((B "#ffb27a"), 16, 22, 28, 28); $g.DrawEllipse($kpen, 16, 22, 28, 28)     # 왼쪽 귀
  $g.FillEllipse((B "#ffb27a"), 96, 22, 28, 28); $g.DrawEllipse($kpen, 96, 22, 28, 28)     # 오른쪽 귀
  $g.FillEllipse((B "#ff9a3c"), 20, 32, 100, 102); $g.DrawEllipse($kpen, 20, 32, 100, 102) # 얼굴
  $g.FillEllipse((B "#ff8fb8"), 30, 86, 20, 14); $g.FillEllipse((B "#ff8fb8"), 90, 86, 20, 14) # 볼
  $g.FillEllipse((B "#4a3524"), 46.5, 64.5, 17, 21); $g.FillEllipse((B "#4a3524"), 76.5, 64.5, 17, 21) # 눈
  $g.FillEllipse((B "#ffffff"), 54.8, 67.8, 6.4, 6.4); $g.FillEllipse((B "#ffffff"), 84.8, 67.8, 6.4, 6.4)
  $mpen = [System.Drawing.Pen]::new((C "#4a3524"), 4.5); $mpen.StartCap = "Round"; $mpen.EndCap = "Round"
  $g.DrawBezier($mpen, 61, 98, 67, 104, 73, 104, 79, 98)                                   # 입
  $g.Restore($k)
}

# 속도선(짧고 굵은 사선)
function Dash {
  param($g, [single]$x, [single]$y, [single]$len, [single]$w, [single]$deg, [string]$col)
  $st = $g.Save(); $g.TranslateTransform($x, $y); $g.RotateTransform($deg)
  $pen = [System.Drawing.Pen]::new((C $col), $w); $pen.StartCap = "Round"; $pen.EndCap = "Round"
  $g.DrawLine($pen, 0, 0, 0, $len); $g.Restore($st)
}

# ============ OG 이미지 (참고용 — $MAKE_OG 가 $true 일 때만) ============
if ($MAKE_OG) {
$w = 1200; $h = 630
$bmp = [System.Drawing.Bitmap]::new($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = "AntiAlias"; $g.InterpolationMode = "HighQualityBicubic"
$g.PixelOffsetMode = "HighQuality"

# 배경 — 따뜻한 그라데이션 + 큰 보케 원
$bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
  [System.Drawing.PointF]::new(0,0), [System.Drawing.PointF]::new($w,$h), (C "#fffdf6"), (C "#ffe9d6"))
$g.FillRectangle($bg, 0, 0, $w, $h)
$g.FillEllipse((BA 150 "#ffd79a"), 860, -190, 520, 520)
$g.FillEllipse((BA 130 "#a8ebdb"), -170, 330, 430, 430)
$g.FillEllipse((BA 110 "#ffc8de"), 600, 470, 340, 340)
$g.FillEllipse((BA 90  "#ffe6a8"), 420, -120, 260, 260)
$g.FillEllipse((BA 160 "#ffd166"), 330, 560, 52, 52)
$g.FillEllipse((BA 160 "#7fdfd0"), 1010, 560, 40, 40)
$g.FillEllipse((BA 160 "#ffb3d1"), 560, 86, 36, 36)

# 브랜드 줄
$lbox = RR 62 44 70 70 20
$lgrad = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
  [System.Drawing.PointF]::new(62,44), [System.Drawing.PointF]::new(132,114), (C "#ff7a1f"), (C "#ffa94d"))
$g.FillPath($lgrad, $lbox)
$lpen = [System.Drawing.Pen]::new((C "#222b40"), 6); $lpen.LineJoin = "Round"; $g.DrawPath($lpen, $lbox)
$null = Txt $g "K" 46 83 57 "#ffffff"
$null = Txt $g "키즈튜터" 40 150 60 "#222b40"
$pill = RR 300 54 150 52 26
$g.FillPath((B "#1fb59b"), $pill)
$g.DrawPath([System.Drawing.Pen]::new((C "#222b40"), 5), $pill)
$null = Txt $g "5세~초6" 27 326 69 "#ffffff"
$pill2 = RR 464 54 208 52 26
$g.FillPath((B "#ff2e8b"), $pill2)
$g.DrawPath([System.Drawing.Pen]::new((C "#222b40"), 5), $pill2)
$null = Txt $g "선생님 510명" 27 490 69 "#ffffff"

# 장식 — 해, 반짝이, 속도선
$g.FillEllipse((B "#ffd166"), 1058, 46, 72, 72)
$g.DrawEllipse([System.Drawing.Pen]::new((C "#222b40"), 5), 1058, 46, 72, 72)
foreach ($a in 0,45,90,135,180,225,270,315) {
  $st = $g.Save(); $g.TranslateTransform(1094, 82); $g.RotateTransform($a)
  $rpen2 = [System.Drawing.Pen]::new((C "#ffc233"), 9); $rpen2.StartCap = "Round"; $rpen2.EndCap = "Round"
  $g.DrawLine($rpen2, 0, -48, 0, -62); $g.Restore($st)
}
Spark $g 56 300 18 "#1fb59b"
Dash $g 250 152 42 13 -20 "#ff2e8b"
Dash $g 212 168 30 13 -20 "#ffd166"

# 화상수업 화면 (오른쪽 위) — 노트북 + 마스코트 키투 (favicon.svg 와 같은 도형)
$st = $g.Save(); $g.TranslateTransform(1012, 252); $g.RotateTransform(-3)
$scr = RR -140 -102 280 186 22
$g.FillPath((B "#ffffff"), $scr)
$spen = [System.Drawing.Pen]::new((C "#222b40"), 7); $spen.LineJoin = "Round"; $g.DrawPath($spen, $scr)
$inner = RR -122 -84 244 150 14
$g.FillPath((B "#dff6f1"), $inner)

Kitu $g 0 3 1.08

$base = RR -162 86 324 22 11
$g.FillPath((B "#ffffff"), $base); $g.DrawPath($spen, $base)
$g.Restore($st)
Spark $g 866 134 20 "#ff2e8b"
Spark $g 1168 390 15 "#ffd166"

# 헤드라인
$b1 = Sticker $g "유아·초등" 138 64 148 "#ff2e8b" "#ff74b4"
$b2 = Sticker $g "1:1 화상과외" 138 64 300 "#17bfe0" "#6fe4f7"

# 가나다 카드 (오른쪽 아래)
$cards = @(
  @("가", 906, 468, -8, "#ff2e8b"),
  @("나", 998, 494, 6, "#2fa9e6"),
  @("다", 1090, 466, -5, "#1fb59b"))
foreach ($c in $cards) {
  $st = $g.Save(); $g.TranslateTransform([single]$c[1], [single]$c[2]); $g.RotateTransform([single]$c[3])
  $cp = RR -42 -46 84 92 16
  $g.FillPath((B "#ffffff"), $cp)
  $cpen = [System.Drawing.Pen]::new((C "#222b40"), 6); $cpen.LineJoin = "Round"; $g.DrawPath($cpen, $cp)
  $tp = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $tp.AddString([string]$c[0], $FAM, $FSTYLE, 54, [System.Drawing.PointF]::new(-27, -38), $TYPO)
  $g.FillPath((B ([string]$c[4])), $tp)
  $g.Restore($st)
}

# 아래 리본 — 핵심 혜택
$rb = RR 62 492 700 92 30
$g.FillPath((B "#ffffff"), $rb)
$rpen = [System.Drawing.Pen]::new((C "#222b40"), 7); $rpen.LineJoin = "Round"; $g.DrawPath($rpen, $rb)
$null = Txt $g "한글·파닉스·연산" 36 100 521 "#222b40"
$g.FillRectangle((B "#ffd166"), 420, 514, 6, 48)
$null = Txt $g "무료 20분 체험" 36 452 521 "#e2620a"

$bmp.Save((Join-Path $root "og-image.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
}

# ============ apple-touch-icon ============
$s = 180
$bmp = [System.Drawing.Bitmap]::new($s, $s)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = "AntiAlias"; $g.PixelOffsetMode = "HighQuality"
# 바탕은 사이트 아이보리, 가운데에 마스코트 키투 (favicon.svg 와 같은 얼굴)
$igrad = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
  [System.Drawing.PointF]::new(0,0), [System.Drawing.PointF]::new($s,$s), (C "#fff3e2"), (C "#ffe2c4"))
$g.FillRectangle($igrad, 0, 0, $s, $s)
Kitu $g 90 94 1.22
$bmp.Save((Join-Path $root "apple-touch-icon.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
if ($MAKE_OG) { Write-Host "og-image.png 까지 다시 그림 — 사용자 그림을 덮어썼다!" }
Write-Host "apple-touch-icon.png 생성 완료 (폰트: $famName)"
