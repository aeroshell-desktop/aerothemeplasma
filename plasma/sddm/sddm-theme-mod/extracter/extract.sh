#!/bin/bash

# required as some paths have whitespace
export IFS=$'\t\n'

extractroot="/mnt/extract"

if [ ! -d "$extractroot" ]; then
    echo "Extraction source does not exist"
    exit 1
fi

tmpdir="$(mktemp -d)"

function unpack_pe
{
    filepath="$(echo "$1" | basenc --base64url -d)"
    export unpackdir="$tmpdir/$(basename "$1")"
    7z -tPE x "$extractroot/$filepath" -o"$unpackdir" &>/dev/null
}

function copy_dir
{
    dirpath="$(echo "$1" | basenc --base64url -d)"
    export unpackdir="$tmpdir/$1"
    cp -r "$extractroot/$dirpath" "$unpackdir"
}

function bmp2png
{
    convert "$1/$2" "$3/${2%.bmp}.png"
}

function bmp2png2
{
    convert "$1/$2" "$3/$4"
}

unpack_pe "V2luZG93cy9TeXN0ZW0zMi9pbWFnZXJlcy5kbGwK"

out="$tmpdir/crop"; mkdir -p "$out"

dir="$unpackdir/.rsrc/ICON"

bmp2png2 "$dir" "947.ico" "$out" "dialog-error.png"

copy_dir "UHJvZ3JhbURhdGEvTWljcm9zb2Z0L1VzZXIgQWNjb3VudCBQaWN0dXJlcwo="

out="$tmpdir/crop"; mkdir -p "$out"

dir="$unpackdir"

bmp2png "$dir" "guest.bmp" "$out"
bmp2png "$dir" "user.bmp" "$out"

unpack_pe "V2luZG93cy9CcmFuZGluZy9CYXNlYnJkL2Jhc2VicmQuZGxsCg=="

out="$tmpdir/crop"; mkdir -p "$out"

dir="$unpackdir/.rsrc/BITMAP"

bmp2png2 "$dir" "120.bmp" "$out" "branding-white.png"
bmp2png2 "$dir" "121.bmp" "$out" "branding-black.png"
bmp2png2 "$dir" "1120.bmp" "$out" "branding-white-2.png"
bmp2png2 "$dir" "1121.bmp" "$out" "branding-black-2.png"
bmp2png2 "$dir" "2120.bmp" "$out" "branding-white-3.png"
bmp2png2 "$dir" "2121.bmp" "$out" "branding-black-3.png"

unpack_pe "V2luZG93cy9TeXN0ZW0zMi9hdXRodWkuZGxsCg=="

out="$tmpdir/crop"; mkdir -p "$out"

dir="$unpackdir/.rsrc/BITMAP"

bmp2png "$dir" "12218.bmp" "$out"
bmp2png "$dir" "12219.bmp" "$out"
bmp2png "$dir" "12220.bmp" "$out"
bmp2png "$dir" "12221.bmp" "$out"
bmp2png "$dir" "12222.bmp" "$out"
bmp2png "$dir" "12223.bmp" "$out"

bmp2png "$dir" "12233.bmp" "$out"
bmp2png "$dir" "12234.bmp" "$out"
bmp2png "$dir" "12235.bmp" "$out"
bmp2png "$dir" "12236.bmp" "$out"
bmp2png "$dir" "12237.bmp" "$out"
bmp2png "$dir" "12238.bmp" "$out"

bmp2png "$dir" "12213.bmp" "$out"
bmp2png "$dir" "12214.bmp" "$out"


bmp2png "$dir" "11000.bmp" "$out"
bmp2png "$dir" "11001.bmp" "$out"
bmp2png "$dir" "11002.bmp" "$out"
bmp2png "$dir" "11003.bmp" "$out"

bmp2png "$dir" "12259.bmp" "$out"
bmp2png "$dir" "12260.bmp" "$out"
bmp2png "$dir" "12261.bmp" "$out"
bmp2png "$dir" "12262.bmp" "$out"
bmp2png "$dir" "12263.bmp" "$out"
bmp2png "$dir" "12264.bmp" "$out"
bmp2png "$dir" "12265.bmp" "$out"
bmp2png "$dir" "12266.bmp" "$out"
bmp2png "$dir" "12267.bmp" "$out"
bmp2png "$dir" "12268.bmp" "$out"
bmp2png "$dir" "12269.bmp" "$out"
bmp2png "$dir" "12270.bmp" "$out"
bmp2png "$dir" "12271.bmp" "$out"
bmp2png "$dir" "12272.bmp" "$out"
bmp2png "$dir" "12273.bmp" "$out"

bmp2png "$dir" "12274.bmp" "$out"
bmp2png "$dir" "12275.bmp" "$out"
bmp2png "$dir" "12276.bmp" "$out"
bmp2png "$dir" "12277.bmp" "$out"
bmp2png "$dir" "12278.bmp" "$out"
bmp2png "$dir" "12279.bmp" "$out"
bmp2png "$dir" "12280.bmp" "$out"
bmp2png "$dir" "12281.bmp" "$out"
bmp2png "$dir" "12282.bmp" "$out"
bmp2png "$dir" "12283.bmp" "$out"
bmp2png "$dir" "12284.bmp" "$out"
bmp2png "$dir" "12285.bmp" "$out"
bmp2png "$dir" "12286.bmp" "$out"
bmp2png "$dir" "12287.bmp" "$out"
bmp2png "$dir" "12288.bmp" "$out"
bmp2png "$dir" "12289.bmp" "$out"
bmp2png "$dir" "12290.bmp" "$out"
bmp2png "$dir" "12291.bmp" "$out"

bmp2png "$dir" "12292.bmp" "$out"
bmp2png "$dir" "12293.bmp" "$out"
bmp2png "$dir" "12294.bmp" "$out"
bmp2png "$dir" "12295.bmp" "$out"
bmp2png "$dir" "12296.bmp" "$out"
bmp2png "$dir" "12298.bmp" "$out"
bmp2png "$dir" "12299.bmp" "$out"
bmp2png "$dir" "12300.bmp" "$out"
bmp2png "$dir" "12301.bmp" "$out"
bmp2png "$dir" "12302.bmp" "$out"
bmp2png "$dir" "12303.bmp" "$out"
bmp2png "$dir" "12304.bmp" "$out"
bmp2png "$dir" "12305.bmp" "$out"
bmp2png "$dir" "12306.bmp" "$out"
bmp2png "$dir" "12307.bmp" "$out"
bmp2png "$dir" "12309.bmp" "$out"
bmp2png "$dir" "12310.bmp" "$out"
bmp2png "$dir" "12311.bmp" "$out"
bmp2png "$dir" "12312.bmp" "$out"
bmp2png "$dir" "12313.bmp" "$out"
bmp2png "$dir" "12314.bmp" "$out"
bmp2png "$dir" "12315.bmp" "$out"
bmp2png "$dir" "12316.bmp" "$out"
bmp2png "$dir" "12317.bmp" "$out"
bmp2png "$dir" "12318.bmp" "$out"
bmp2png "$dir" "12320.bmp" "$out"
bmp2png "$dir" "12321.bmp" "$out"
bmp2png "$dir" "12322.bmp" "$out"
bmp2png "$dir" "12323.bmp" "$out"
bmp2png "$dir" "12324.bmp" "$out"

function powerbutton
{
    newname="$1"

    in="$2"
    convert "$in" -crop 5x28+0+0    "$out/$newname-l.png"
    convert "$in" -crop 11x28+5+0   "$out/$newname-m.png"
    convert "$in" -crop 5x28+16+0   "$out/$newname-r.png"

    in="$out/$newname-m.png"
    convert "$in" +repage -resize 28x28\!      "$out/$newname-m-resized.png"
    convert +append "$out/$newname-l.png" "$out/$newname-m-resized.png" "$out/$newname-r.png" "$out/$newname.png"
}

powerbutton "power-hover-focus" "$out/12292.png"
powerbutton "power-focus"       "$out/12293.png"
powerbutton "power-hover"       "$out/12294.png"
powerbutton "power"             "$out/12296.png"
powerbutton "power-active"      "$out/12295.png"

bmp2png2 "$dir" "12215.bmp" "$out" "power-glyph.png"
bmp2png2 "$dir" "12216.bmp" "$out" "power-glyph-info.png"
bmp2png2 "$dir" "12217.bmp" "$out" "power-glyph-arrow.png"



function button
{
    newname="$1"

    in="$2"
    convert "$in" -crop 5x28+0+0    "$out/$newname-l.png"
    convert "$in" -crop 25x28+5+0   "$out/$newname-m.png"
    convert "$in" -crop 5x28+30+0   "$out/$newname-r.png"

    in="$out/$newname-m.png"
    convert "$in" +repage -resize 83x28\!     "$out/$newname-m-resized.png"
    convert +append "$out/$newname-l.png" "$out/$newname-m-resized.png" "$out/$newname-r.png" "$out/$newname.png"
}

button "button-focus"       "$out/12259.png"
button "button-hover"       "$out/12260.png"
button "button-hover-focus" "$out/12261.png"
button "button-active"      "$out/12262.png"
button "button"             "$out/12263.png"

function button2
{
    newname="$1"

    in="$2"
    convert "$in" -crop 5x28+0+0    "$out/$newname-l.png"
    convert "$in" -crop 25x28+5+0   "$out/$newname-m.png"
    convert "$in" -crop 5x28+30+0   "$out/$newname-r.png"

    in="$out/$newname-m.png"
    convert "$in" +repage -resize 98x28\!    "$out/$newname-m-resized.png"
    convert +append "$out/$newname-l.png" "$out/$newname-m-resized.png" "$out/$newname-r.png" "$out/$newname.png"
}

button2 "switch-user-button-focus"       "$out/12259.png"
button2 "switch-user-button-hover"       "$out/12260.png"
button2 "switch-user-button-hover-focus" "$out/12261.png"
button2 "switch-user-button-active"      "$out/12262.png"
button2 "switch-user-button"             "$out/12263.png"

function button3
{
    newname="$1"

    in="$2"
    convert "$in" -crop 5x28+0+0    "$out/$newname-l.png"
    convert "$in" -crop 25x28+5+0   "$out/$newname-m.png"
    convert "$in" -crop 5x28+30+0   "$out/$newname-r.png"

    in="$out/$newname-m.png"
    convert "$in" +repage -resize 28x28\!    "$out/$newname-m-resized.png"
    convert +append "$out/$newname-l.png" "$out/$newname-m-resized.png" "$out/$newname-r.png" "$out/$newname.png"
}

button3 "access-button-focus"       "$out/12259.png"
button3 "access-button-hover"       "$out/12260.png"
button3 "access-button-hover-focus" "$out/12261.png"
button3 "access-button-active"      "$out/12262.png"
button3 "access-button"             "$out/12263.png"

function inputbox
{
    newname="$1"

    in="$2"
    convert "$in" -crop 4x4+0+0     "$out/$newname-nw.png"
    convert "$in" -crop 4x4+5+0     "$out/$newname-ne.png"
    convert "$in" -crop 4x4+5+5     "$out/$newname-se.png"
    convert "$in" -crop 4x4+0+5     "$out/$newname-sw.png"

    convert "$in" -crop 1x4+4+0     "$out/$newname-n.png"
    convert "$in" -crop 1x4+4+5     "$out/$newname-s.png"
    convert "$in" -crop 4x1+5+4     "$out/$newname-e.png"
    convert "$in" -crop 4x1+0+4     "$out/$newname-w.png"

    convert "$in" -crop 1x1+4+4     "$out/$newname-c.png"

    in="$out/$newname-n.png"
    convert "$in" +repage -resize 217x4\!      "$out/$newname-n-resized.png"
    in="$out/$newname-s.png"
    convert "$in" +repage -resize 217x4\!      "$out/$newname-s-resized.png"
    in="$out/$newname-e.png"
    convert "$in" +repage -resize 4x17\!       "$out/$newname-e-resized.png"
    in="$out/$newname-w.png"
    convert "$in" +repage -resize 4x17\!       "$out/$newname-w-resized.png"
    in="$out/$newname-c.png"
    convert "$in" +repage -resize 217x17\!     "$out/$newname-c-resized.png"

    convert +append "$out/$newname-nw.png" "$out/$newname-n-resized.png" "$out/$newname-ne.png" "$out/$newname-top.png"
    convert +append "$out/$newname-w-resized.png" "$out/$newname-c-resized.png" "$out/$newname-e-resized.png" "$out/$newname-middle.png"
    convert +append "$out/$newname-sw.png" "$out/$newname-s-resized.png" "$out/$newname-se.png" "$out/$newname-bottom.png"

    convert -append "$out/$newname-top.png" "$out/$newname-middle.png" "$out/$newname-bottom.png" "$out/$newname.png"
}

inputbox "input-inactive" "$out/11000.png"
inputbox "input-focus"    "$out/11001.png"
inputbox "input-hover"    "$out/11002.png"
inputbox "input"          "$out/11003.png"

ln -sfT "$tmpdir" nonredist

echo Done
