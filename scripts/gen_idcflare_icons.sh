#!/usr/bin/env bash
# 从 idcflare.com 官方 logo 重新生成全部应用图标资产(Android + iOS + 设置页预览)。
# 依赖:ImageMagick(magick)、bc、curl。用法:bash scripts/gen_idcflare_icons.sh
# 素材:site basic-info 的 logo_small(896x896 红圆白 IF. 字标,brand red #A81818)。
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

LOGO_URL='https://idcflare.com/uploads/default/original/1X/27321bd8c4301b325bf5e4524772bb39ece5424e.png'
RED='#A81818'
DARK='#1C1C1E'
LIGHT='#F0F0F3'

cd "$WORK"
curl -fsSL --max-time 30 -o logo_small.png "$LOGO_URL"

# ── 字标 mask(白字含六边形句点;level 保留抗锯齿,crop 为字标包围盒)──
magick logo_small.png -colorspace gray -level 40%,92% \
  -crop 520x416+188+240 +repage mask.png
magick -size 520x416 xc:white mask.png -alpha off \
  -compose CopyOpacity -composite letters_white.png
magick -size 520x416 xc:"$RED" mask.png -alpha off \
  -compose CopyOpacity -composite letters_red.png

circle_on() { # <尺寸> <底色|none> <圆径比> <输出>
  local size=$1 bg=$2 ratio=$3 out=$4
  local d; d=$(printf '%.0f' "$(echo "$size * $ratio" | bc -l)")
  magick -size "${size}x${size}" xc:"$bg" \
    \( logo_small.png -resize "${d}x${d}" \) \
    -gravity center -composite -strip "$out"
}

letters_on() { # <尺寸> <底色|none> <字宽比> <white|red> <输出>
  local size=$1 bg=$2 ratio=$3 src=$4 out=$5
  local w; w=$(printf '%.0f' "$(echo "$size * $ratio" | bc -l)")
  magick -size "${size}x${size}" xc:"$bg" \
    \( "letters_${src}.png" -resize "${w}x" \) \
    -gravity center -composite -strip "$out"
}

rounded_letters() { # <尺寸> <底色> <圆角比> <字宽比> <white|red> <输出>
  local size=$1 bg=$2 rr=$3 ratio=$4 src=$5 out=$6
  local r; r=$(printf '%.0f' "$(echo "$size * $rr" | bc -l)")
  local w; w=$(printf '%.0f' "$(echo "$size * $ratio" | bc -l)")
  magick -size "${size}x${size}" xc:none \
    -fill "$bg" -draw "roundrectangle 0,0,$((size-1)),$((size-1)),$r,$r" \
    \( "letters_${src}.png" -resize "${w}x" \) \
    -gravity center -compose over -composite -strip "$out"
}

# ── iOS(1024 全出血方形,系统裁圆角;去 alpha)──
IOSD="$REPO/ios/Runner/Assets.xcassets"
circle_on 1024 white   0.84 "$IOSD/AppIcon.appiconset/AppIcon-Light-1024x1024.png"
circle_on 1024 "$DARK" 0.84 "$IOSD/AppIcon.appiconset/AppIcon-Dark-1024x1024.png"
letters_on 1024 "$LIGHT" 0.55 red "$IOSD/ModernIcon.appiconset/ModernIcon-Light-1024x1024.png"
letters_on 1024 "$DARK"  0.55 red "$IOSD/ModernIcon.appiconset/ModernIcon-Dark-1024x1024.png"
for f in "$IOSD"/AppIcon.appiconset/AppIcon-*.png "$IOSD"/ModernIcon.appiconset/ModernIcon-*.png; do
  magick "$f" -alpha off -strip "$f"
done

# ── Android 自适应前景/monochrome(108dp 网格,内容限 66dp 安全区)──
RES="$REPO/android/app/src/main/res"
declare -A DPI=( [mdpi]=108 [hdpi]=162 [xhdpi]=216 [xxhdpi]=324 [xxxhdpi]=432 )
for dpi in "${!DPI[@]}"; do
  c=${DPI[$dpi]}
  d="$RES/drawable-$dpi"; mkdir -p "$d"
  circle_on "$c" none 0.611 "$d/ic_launcher_foreground.png"
  letters_on "$c" none 0.46 white "$d/ic_launcher_monochrome.png"
  cp "$d/ic_launcher_monochrome.png" "$d/ic_launcher_modern_monochrome.png"
  letters_on "$c" none 0.46 red "$d/ic_launcher_modern_foreground.png"
  cp "$d/ic_launcher_modern_foreground.png" "$d/ic_launcher_modern_light_foreground.png"
done

# ── Android 传统图标(API<26 免遮罩,自带形状)──
declare -A LEG=( [mdpi]=48 [hdpi]=72 [xhdpi]=96 [xxhdpi]=144 [xxxhdpi]=192 )
for dpi in "${!LEG[@]}"; do
  c=${LEG[$dpi]}
  circle_on "$c" none 0.94 "$RES/mipmap-$dpi/ic_launcher.png"
  cp "$RES/mipmap-$dpi/ic_launcher.png" "$RES/mipmap-night-$dpi/ic_launcher.png"
  rounded_letters "$c" "$LIGHT" 0.22 0.55 red "$RES/mipmap-$dpi/ic_launcher_modern.png"
  rounded_letters "$c" "$DARK"  0.22 0.55 red "$RES/mipmap-night-$dpi/ic_launcher_modern.png"
done

# ── 设置页图标选择器预览(256,BoxFit.cover 方图)──
AST="$REPO/assets/images"
circle_on 256 white   0.82 "$AST/icon_default_preview.png"
circle_on 256 "$DARK" 0.82 "$AST/icon_default_dark_preview.png"
letters_on 256 "$LIGHT" 0.55 red "$AST/icon_modern_light_preview.png"
letters_on 256 "$DARK"  0.55 red "$AST/icon_modern_preview.png"

echo '图标资产生成完毕'
