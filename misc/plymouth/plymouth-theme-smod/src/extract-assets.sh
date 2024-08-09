#!/bin/bash

# change to your resolution
BACKGROUND_RES=1920x1080

# required as some paths have whitespace
export IFS=$'\t\n'

extractroot="/mnt/extract"

if [ ! -d "$extractroot" ]; then
    echo "Extraction source does not exist"
    exit 1
fi

if [ ! -f "/usr/local/bin/convert" ]; then
    echo "To run the extraction script a patched version of imagemagick is required,"
    echo "Due to recent code changes in imagemagick, activity.bmp will now fail to convert."
    echo "Use the scripts in the imagemagick subdirectory to install the patched version"
    echo "into /usr/local, then run this script again. Once assets are extracted you may"
    echo "uninstall the patched version."
    exit 1
fi

tmpdir="$(mktemp -d)"

function unpack_pe()
{
    filepath="$(echo "$1" | basenc --base64url -d)"
    export unpackdir="$tmpdir/$(basename "$1")"
    7z x "$extractroot/$filepath" -o"$unpackdir" &>/dev/null
}

function bmp2png()
{
    /usr/bin/convert "$1/$2" "$3/$4"
}


unpack_pe "V2luZG93cy9TeXN0ZW0zMi9ib290cmVzLmRsbAo="
# boot animation
out="$tmpdir/crop"; mkdir -p "$out"
dir="$unpackdir"
in="$dir/activity.bmp"
LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/convert -define bmp:ignore-filesize=True "$in" "$out/activity.png"
in="$out/activity.png"
/usr/bin/convert "$in" -crop "1x105@" "$out/boot%d.png"
for((i=104;i>=0;i--)); do mv "$out/boot$i.png" "$out/boot$((i + 1)).png"; done


unpack_pe "V2luZG93cy9CcmFuZGluZy9CYXNlYnJkL2Jhc2VicmQuZGxsCg=="
# branding
out="$tmpdir/crop"; mkdir -p "$out"
dir="$unpackdir/.rsrc/BITMAP"
bmp2png "$dir" "120.bmp" "$out" "branding-white.png"


unpack_pe "V2luZG93cy9TeXN0ZW0zMi9pbWFnZXJlcy5kbGwK"
# wallpaper
dir="$unpackdir/.rsrc/IMAGE"
cp "$dir/5038" "$out/background.jpg"
/usr/bin/convert "$out/background.jpg" -filter Catrom -resize ${BACKGROUND_RES}! "$out/background-resized.png"
# shutdown animation
dir="$unpackdir/.rsrc/BITMAP"
bmp2png "$dir" "5002.bmp" "$out" "5002.png"
in="$out/5002.png"
/usr/bin/convert "$in" -crop "18x1@" "$out/shutdown%d.png"
for((i=17;i>=0;i--)); do mv "$out/shutdown$i.png" "$out/shutdown$((i + 1)).png"; done


unpack_pe "V2luZG93cy9TeXN0ZW0zMi9hdXRodWkuZGxsCg=="
# password input
out="$tmpdir/crop"; mkdir -p "$out"
dir="$unpackdir/.rsrc/BITMAP"
bmp2png "$dir" "11001.bmp" "$out" "11001.png"

function inputbox
{
    newname="$1"

    in="$2"
    /usr/bin/convert "$in" -crop 4x4+0+0     "$out/$newname-nw.png"
    /usr/bin/convert "$in" -crop 4x4+5+0     "$out/$newname-ne.png"
    /usr/bin/convert "$in" -crop 4x4+5+5     "$out/$newname-se.png"
    /usr/bin/convert "$in" -crop 4x4+0+5     "$out/$newname-sw.png"

    /usr/bin/convert "$in" -crop 1x4+4+0     "$out/$newname-n.png"
    /usr/bin/convert "$in" -crop 1x4+4+5     "$out/$newname-s.png"
    /usr/bin/convert "$in" -crop 4x1+5+4     "$out/$newname-e.png"
    /usr/bin/convert "$in" -crop 4x1+0+4     "$out/$newname-w.png"

    /usr/bin/convert "$in" -crop 1x1+4+4     "$out/$newname-c.png"

    in="$out/$newname-n.png"
    /usr/bin/convert "$in" +repage -resize 217x4\!      "$out/$newname-n-resized.png"
    in="$out/$newname-s.png"
    /usr/bin/convert "$in" +repage -resize 217x4\!      "$out/$newname-s-resized.png"
    in="$out/$newname-e.png"
    /usr/bin/convert "$in" +repage -resize 4x17\!       "$out/$newname-e-resized.png"
    in="$out/$newname-w.png"
    /usr/bin/convert "$in" +repage -resize 4x17\!       "$out/$newname-w-resized.png"
    in="$out/$newname-c.png"
    /usr/bin/convert "$in" +repage -resize 217x17\!     "$out/$newname-c-resized.png"

    /usr/bin/convert +append "$out/$newname-nw.png" "$out/$newname-n-resized.png" "$out/$newname-ne.png" "$out/$newname-top.png"
    /usr/bin/convert +append "$out/$newname-w-resized.png" "$out/$newname-c-resized.png" "$out/$newname-e-resized.png" "$out/$newname-middle.png"
    /usr/bin/convert +append "$out/$newname-sw.png" "$out/$newname-s-resized.png" "$out/$newname-se.png" "$out/$newname-bottom.png"

    /usr/bin/convert -append "$out/$newname-top.png" "$out/$newname-middle.png" "$out/$newname-bottom.png" "$out/$newname.png"
}

inputbox "input-focus" "$out/11001.png"


# text
echo "U3RhcnRpbmcgV2luZG93cwo=" | basenc --base64url -d > "$out/maintext.txt"
echo "wqkgTWljcm9zb2Z0IENvcnBvcmF0aW9uCg==" | basenc --base64url -d > "$out/branding.txt"
FONT="$(echo "U2Vnb2UgVUkK" | basenc --base64url -d)"

pango-view \
    --font="$FONT" \
    --background="transparent" \
    --foreground="#ffffff" \
    --dpi=144 \
    --antialias=gray \
    --hinting=slight \
    --hint-metrics=on \
    -qo "$out/maintext.png" "$out/maintext.txt"

pango-view \
    --font="$FONT" \
    --background="transparent" \
    --foreground="#777777" \
    --dpi=90 \
    --antialias=gray \
    --hinting=slight \
    --hint-metrics=on \
    -qo "$out/branding.png" "$out/branding.txt"

# bullet
inkscape bullet.svg -o "$out/bullet.png"

ln -sfT "$tmpdir" nonredist

echo Done
