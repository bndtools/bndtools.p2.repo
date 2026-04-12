bg_url="https://avatars.githubusercontent.com/u/136694522?s=280&v=4"
font="/System/Library/Fonts/Supplemental/Arial Bold.ttf"

curl -L "$bg_url" -o bg.png

magick -background none -fill white \
  -font "$font" \
  -pointsize 260 \
  label:bnd \
  -trim +repage \
  -gravity center \
  -extent 512x512 \
  text.png

magick text.png -background black -flatten preview-text.png

magick bg.png text.png -gravity center -composite favicon_base.png

for s in 16 32 64 128 256; do
  magick favicon_base.png -resize ${s}x${s} "favicon-${s}.png"
done

magick favicon-16.png favicon-32.png favicon-64.png favicon-128.png favicon-256.png favicon.ico

magick bg.png -resize 1024x1024 bg_large.png

magick bg_large.png \
  \( text.png -resize 840x840 \) \
  -gravity center \
  -composite \
  hero.png