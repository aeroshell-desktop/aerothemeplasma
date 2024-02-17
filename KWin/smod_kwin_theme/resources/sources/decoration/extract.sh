#!/bin/bash

# required as some paths have whitespace
export IFS=$'\t\n'

extractroot="/mnt/extract"

if [ ! -d "$extractroot" ]; then
    echo "Extraction source does not exist"
    exit 1
fi

tmpdir="$(mktemp -d)"

function unpack
{
    filepath="$(echo "$1" | basenc --base64url -d)"
    export unpackdir="$tmpdir/$(basename "$1")"
    7z x "$extractroot/$filepath" -o"$unpackdir" &>/dev/null
}

function unpack_pe
{
    filepath="$(echo "$1" | basenc --base64url -d)"
    export unpackdir="$tmpdir/$(basename "$1")"
    7z -tPE x "$extractroot/$filepath" -o"$unpackdir" &>/dev/null
}

unpack_pe "V2luZG93cy9SZXNvdXJjZXMvVGhlbWVzL0Flcm8vYWVyby5tc3N0eWxlcwo="

out="$tmpdir/crop"; mkdir -p "$out"

dir="$unpackdir/.rsrc/STREAM"

in="$dir/971"

# effects

convert "$in" -crop 228x175+327+0   "$out/framecornereffect.png"
convert "$in" -crop 228x175+327+175 "$out/framecornereffect-unfocus.png"

# bottom sizing margin of 2 (118 - 2 = 116)
convert "$in" -crop 7x116+0+0       "$out/sidehighlight.png"
convert "$in" -crop 7x116+0+118     "$out/sidehighlight-unfocus.png"

convert "$in" -crop 802x604+555+0   "$out/reflections.png"



# glyphs

convert "$in" -crop 14x14+0+484     "$out/close-glyph-96.png"
convert "$in" -crop 14x14+0+498     "$out/close-glyph-hover-96.png"
convert "$in" -crop 14x14+0+512     "$out/close-glyph-active-96.png"
convert "$in" -crop 14x14+0+526     "$out/close-glyph-inactive-96.png"

convert "$in" -crop 14x14+0+596     "$out/minimize-glyph-96.png"
convert "$in" -crop 14x14+0+610     "$out/minimize-glyph-hover-96.png"
convert "$in" -crop 14x14+0+624     "$out/minimize-glyph-active-96.png"
convert "$in" -crop 14x14+0+638     "$out/minimize-glyph-inactive-96.png"

convert "$in" -crop 16x14+15+60     "$out/maximize-glyph-96.png"
convert "$in" -crop 16x14+15+74     "$out/maximize-glyph-hover-96.png"
convert "$in" -crop 16x14+15+88     "$out/maximize-glyph-active-96.png"
convert "$in" -crop 16x14+15+102    "$out/maximize-glyph-inactive-96.png"

convert "$in" -crop 14x14+0+540     "$out/restore-glyph-96.png"
convert "$in" -crop 14x14+0+554     "$out/restore-glyph-hover-96.png"
convert "$in" -crop 14x14+0+568     "$out/restore-glyph-active-96.png"
convert "$in" -crop 14x14+0+582     "$out/restore-glyph-inactive-96.png"



in="$out/close-glyph-96.png"
convert "$in" +repage -crop 11x10+1+2       "$out/close-glyph-96-small.png"
in="$out/close-glyph-hover-96.png"
convert "$in" +repage -crop 11x10+1+2       "$out/close-glyph-hover-96-small.png"
in="$out/close-glyph-active-96.png"
convert "$in" +repage -crop 11x10+1+2       "$out/close-glyph-active-96-small.png"
in="$out/close-glyph-inactive-96.png"
convert "$in" +repage -crop 11x10+1+2       "$out/close-glyph-inactive-96-small.png"



in="$out/minimize-glyph-96.png"
convert "$in" +repage -crop 12x5+1+7       "$out/minimize-glyph-96-small.png"
in="$out/minimize-glyph-hover-96.png"
convert "$in" +repage -crop 12x5+1+7       "$out/minimize-glyph-hover-96-small.png"
in="$out/minimize-glyph-active-96.png"
convert "$in" +repage -crop 12x5+1+7       "$out/minimize-glyph-active-96-small.png"
in="$out/minimize-glyph-inactive-96.png"
convert "$in" +repage -crop 12x5+1+7       "$out/minimize-glyph-inactive-96-small.png"


in="$out/maximize-glyph-96.png"
convert "$in" +repage -crop 12x10+3+2       "$out/maximize-glyph-96-small.png"
in="$out/maximize-glyph-hover-96.png"
convert "$in" +repage -crop 12x10+3+2       "$out/maximize-glyph-hover-96-small.png"
in="$out/maximize-glyph-active-96.png"
convert "$in" +repage -crop 12x10+3+2       "$out/maximize-glyph-active-96-small.png"
in="$out/maximize-glyph-inactive-96.png"
convert "$in" +repage -crop 12x10+3+2       "$out/maximize-glyph-inactive-96-small.png"


in="$out/restore-glyph-96.png"
convert "$in" +repage -crop 12x12+1+1       "$out/restore-glyph-96-small.png"
in="$out/restore-glyph-hover-96.png"
convert "$in" +repage -crop 12x12+1+1       "$out/restore-glyph-hover-96-small.png"
in="$out/restore-glyph-active-96.png"
convert "$in" +repage -crop 12x12+1+1       "$out/restore-glyph-active-96-small.png"
in="$out/restore-glyph-inactive-96.png"
convert "$in" +repage -crop 12x12+1+1       "$out/restore-glyph-inactive-96-small.png"




# buttons

in="$dir/971"

convert "$in" -crop 31x22+83+88     "$out/minimize.png"
convert "$in" -crop 31x22+83+110    "$out/minimize-hover.png"
convert "$in" -crop 31x22+83+132    "$out/minimize-active.png"
convert "$in" -crop 31x22+83+154    "$out/minimize-notresponding.png"

convert "$in" -crop 31x22+83+352    "$out/maximize.png"
convert "$in" -crop 31x22+83+374    "$out/maximize-hover.png"
convert "$in" -crop 31x22+83+396    "$out/maximize-active.png"
convert "$in" -crop 31x22+83+418    "$out/maximize-notresponding.png"

convert "$in" -crop 51x22+83+568    "$out/close.png"
convert "$in" -crop 51x22+83+590    "$out/close-hover.png"
convert "$in" -crop 51x22+83+612    "$out/close-active.png"
convert "$in" -crop 51x22+83+634    "$out/close-notresponding.png"

convert "$in" -crop 31x22+83+264    "$out/minimize-unfocus.png"
convert "$in" -crop 31x22+83+286    "$out/minimize-unfocus-hover.png"
convert "$in" -crop 31x22+83+308    "$out/minimize-unfocus-active.png"
convert "$in" -crop 31x22+83+330    "$out/minimize-unfocus-notresponding.png"

convert "$in" -crop 31x22+83+176    "$out/maximize-unfocus.png"
convert "$in" -crop 31x22+83+198    "$out/maximize-unfocus-hover.png"
convert "$in" -crop 31x22+83+220    "$out/maximize-unfocus-active.png"
convert "$in" -crop 31x22+83+242    "$out/maximize-unfocus-notresponding.png"

convert "$in" -crop 51x22+134+0     "$out/close-unfocus.png"
convert "$in" -crop 51x22+134+22    "$out/close-unfocus-hover.png"
convert "$in" -crop 51x22+134+44    "$out/close-unfocus-active.png"
convert "$in" -crop 51x22+134+66    "$out/close-unfocus-notresponding.png"

# cropped buttons



in="$out/minimize.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-cropped.png"

in="$out/minimize-hover.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-hover-cropped.png"

in="$out/minimize-active.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-active-cropped.png"

in="$out/minimize-notresponding.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-notresponding-cropped.png"


in="$out/maximize.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-cropped.png"

in="$out/maximize-hover.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-hover-cropped.png"

in="$out/maximize-active.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-active-cropped.png"

in="$out/maximize-notresponding.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-notresponding-cropped.png"


in="$out/close.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-cropped.png"

in="$out/close-hover.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-hover-cropped.png"

in="$out/close-active.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-active-cropped.png"

in="$out/close-notresponding.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-notresponding-cropped.png"





in="$out/maximize-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-cropped-c.png"
convert +append "$out/maximize-cropped-l.png" "$out/maximize-cropped-c.png" "$out/maximize-cropped-r.png" "$out/maximize-cropped-small.png"

in="$out/maximize-hover-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-hover-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-hover-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-hover-cropped-c.png"
convert +append "$out/maximize-hover-cropped-l.png" "$out/maximize-hover-cropped-c.png" "$out/maximize-hover-cropped-r.png" "$out/maximize-hover-cropped-small.png"

in="$out/maximize-active-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-active-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-active-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-active-cropped-c.png"
convert +append "$out/maximize-active-cropped-l.png" "$out/maximize-active-cropped-c.png" "$out/maximize-active-cropped-r.png" "$out/maximize-active-cropped-small.png"

in="$out/maximize-notresponding-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-notresponding-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-notresponding-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-notresponding-cropped-c.png"
convert +append "$out/maximize-notresponding-cropped-l.png" "$out/maximize-notresponding-cropped-c.png" "$out/maximize-notresponding-cropped-r.png" "$out/maximize-notresponding-cropped-small.png"













in="$out/minimize-unfocus.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-unfocus-cropped.png"

in="$out/minimize-unfocus-hover.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-unfocus-hover-cropped.png"

in="$out/minimize-unfocus-active.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-unfocus-active-cropped.png"

in="$out/minimize-unfocus-notresponding.png"
convert "$in" +repage -crop 29x20+1+1       "$out/minimize-unfocus-notresponding-cropped.png"


in="$out/maximize-unfocus.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-unfocus-cropped.png"

in="$out/maximize-unfocus-hover.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-unfocus-hover-cropped.png"

in="$out/maximize-unfocus-active.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-unfocus-active-cropped.png"

in="$out/maximize-unfocus-notresponding.png"
convert "$in" +repage -crop 29x20+1+1       "$out/maximize-unfocus-notresponding-cropped.png"


in="$out/close-unfocus.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-unfocus-cropped.png"

in="$out/close-unfocus-hover.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-unfocus-hover-cropped.png"

in="$out/close-unfocus-active.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-unfocus-active-cropped.png"

in="$out/close-unfocus-notresponding.png"
convert "$in" +repage -crop 49x20+1+1       "$out/close-unfocus-notresponding-cropped.png"





in="$out/maximize-unfocus-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-unfocus-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-unfocus-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-unfocus-cropped-c.png"
convert +append "$out/maximize-unfocus-cropped-l.png" "$out/maximize-unfocus-cropped-c.png" "$out/maximize-unfocus-cropped-r.png" "$out/maximize-unfocus-cropped-small.png"

in="$out/maximize-unfocus-hover-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-unfocus-hover-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-unfocus-hover-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-unfocus-hover-cropped-c.png"
convert +append "$out/maximize-unfocus-hover-cropped-l.png" "$out/maximize-unfocus-hover-cropped-c.png" "$out/maximize-unfocus-hover-cropped-r.png" "$out/maximize-unfocus-hover-cropped-small.png"

in="$out/maximize-unfocus-active-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-unfocus-active-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-unfocus-active-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-unfocus-active-cropped-c.png"
convert +append "$out/maximize-unfocus-active-cropped-l.png" "$out/maximize-unfocus-active-cropped-c.png" "$out/maximize-unfocus-active-cropped-r.png" "$out/maximize-unfocus-active-cropped-small.png"

in="$out/maximize-unfocus-notresponding-cropped.png"
convert "$in" +repage -crop 13x20+0+0       "$out/maximize-unfocus-notresponding-cropped-l.png"
convert "$in" +repage -crop 13x20+16+0      "$out/maximize-unfocus-notresponding-cropped-r.png"
convert "$in" +repage -crop 1x20+14+0       "$out/maximize-unfocus-notresponding-cropped-c.png"
convert +append "$out/maximize-unfocus-notresponding-cropped-l.png" "$out/maximize-unfocus-notresponding-cropped-c.png" "$out/maximize-unfocus-notresponding-cropped-r.png" "$out/maximize-unfocus-notresponding-cropped-small.png"



















in="$out/close-cropped.png"
convert "$in" +repage -crop 20x6+0+0        "$out/close-nw.png"
convert "$in" +repage -crop 9x6+20+0        "$out/close-n.png"
convert "$in" +repage -crop 20x6+29+0       "$out/close-ne.png"
convert "$in" +repage -crop 20x6+29+6       "$out/close-e.png"
convert "$in" +repage -crop 20x8+29+12      "$out/close-se.png"
convert "$in" +repage -crop 9x8+20+12       "$out/close-s.png"
convert "$in" +repage -crop 20x8+0+12       "$out/close-sw.png"
convert "$in" +repage -crop 20x6+0+6        "$out/close-w.png"
convert "$in" +repage -crop 9x6+20+6        "$out/close-c.png"



in="$out/close-hover-cropped.png"
convert "$in" +repage -crop 20x6+0+0        "$out/close-hover-nw.png"
convert "$in" +repage -crop 9x6+20+0        "$out/close-hover-n.png"
convert "$in" +repage -crop 20x6+29+0       "$out/close-hover-ne.png"
convert "$in" +repage -crop 20x6+29+6       "$out/close-hover-e.png"
convert "$in" +repage -crop 20x8+29+12      "$out/close-hover-se.png"
convert "$in" +repage -crop 9x8+20+12       "$out/close-hover-s.png"
convert "$in" +repage -crop 20x8+0+12       "$out/close-hover-sw.png"
convert "$in" +repage -crop 20x6+0+6        "$out/close-hover-w.png"
convert "$in" +repage -crop 9x6+20+6        "$out/close-hover-c.png"



in="$out/close-active-cropped.png"
convert "$in" +repage -crop 20x6+0+0        "$out/close-active-nw.png"
convert "$in" +repage -crop 9x6+20+0        "$out/close-active-n.png"
convert "$in" +repage -crop 20x6+29+0       "$out/close-active-ne.png"
convert "$in" +repage -crop 20x6+29+6       "$out/close-active-e.png"
convert "$in" +repage -crop 20x8+29+12      "$out/close-active-se.png"
convert "$in" +repage -crop 9x8+20+12       "$out/close-active-s.png"
convert "$in" +repage -crop 20x8+0+12       "$out/close-active-sw.png"
convert "$in" +repage -crop 20x6+0+6        "$out/close-active-w.png"
convert "$in" +repage -crop 9x6+20+6        "$out/close-active-c.png"



in="$out/close-notresponding-cropped.png"
convert "$in" +repage -crop 20x6+0+0        "$out/close-notresponding-nw.png"
convert "$in" +repage -crop 9x6+20+0        "$out/close-notresponding-n.png"
convert "$in" +repage -crop 20x6+29+0       "$out/close-notresponding-ne.png"
convert "$in" +repage -crop 20x6+29+6       "$out/close-notresponding-e.png"
convert "$in" +repage -crop 20x8+29+12      "$out/close-notresponding-se.png"
convert "$in" +repage -crop 9x8+20+12       "$out/close-notresponding-s.png"
convert "$in" +repage -crop 20x8+0+12       "$out/close-notresponding-sw.png"
convert "$in" +repage -crop 20x6+0+6        "$out/close-notresponding-w.png"
convert "$in" +repage -crop 9x6+20+6        "$out/close-notresponding-c.png"







function extract_frame_top_bottom
{
    frame="$1"

    in="$out/${frame}-top.png"

    convert "$in" +repage -crop 9x9+1+1        "$out/${frame}-nw.png"
    convert "$in" +repage -crop 1x9+10+1       "$out/${frame}-n.png"
    convert "$in" +repage -crop 9x9+11+1       "$out/${frame}-ne.png"
    convert "$in" +repage -crop 9x9+1+28       "$out/${frame}-unfocus-nw.png"
    convert "$in" +repage -crop 1x9+10+28      "$out/${frame}-unfocus-n.png"
    convert "$in" +repage -crop 9x9+11+28      "$out/${frame}-unfocus-ne.png"

    convert "$in" +repage -crop 2x2+8+24       "$out/${frame}-nw-inner.png"
    convert "$in" +repage -crop 1x2+10+24      "$out/${frame}-n-inner.png"
    convert "$in" +repage -crop 2x2+11+24      "$out/${frame}-ne-inner.png"
    convert "$in" +repage -crop 2x2+8+51       "$out/${frame}-unfocus-nw-inner.png"
    convert "$in" +repage -crop 1x2+10+51      "$out/${frame}-unfocus-n-inner.png"
    convert "$in" +repage -crop 2x2+11+51      "$out/${frame}-unfocus-ne-inner.png"

    in="$out/${frame}-bottom.png"

    convert "$in" +repage -crop 7x9+1+1       "$out/${frame}-sw-l.png"
    convert "$in" +repage -crop 2x7+8+3       "$out/${frame}-sw-r.png"
    convert +append -gravity South -background none "$out/${frame}-sw-l.png" "$out/${frame}-sw-r.png" "$out/${frame}-sw.png"

    convert "$in" +repage -crop 1x7+10+3 "$out/${frame}-s-b.png"
    convert "$out/${frame}-s-b.png" +repage -gravity South -background none -extent 1x9 "$out/${frame}-s.png"

    convert "$in" +repage -crop 2x7+11+3       "$out/${frame}-se-l.png"
    convert "$in" +repage -crop 7x9+13+1       "$out/${frame}-se-r.png"
    convert +append -gravity South -background none "$out/${frame}-se-l.png" "$out/${frame}-se-r.png" "$out/${frame}-se.png"

    convert "$in" +repage -crop 7x9+1+12       "$out/${frame}-unfocus-sw-l.png"
    convert "$in" +repage -crop 2x7+8+14       "$out/${frame}-unfocus-sw-r.png"
    convert +append -gravity South -background none "$out/${frame}-unfocus-sw-l.png" "$out/${frame}-unfocus-sw-r.png" "$out/${frame}-unfocus-sw.png"

    convert "$in" +repage -crop 1x7+10+14 "$out/${frame}-unfocus-s-b.png"
    convert "$out/${frame}-unfocus-s-b.png" +repage -gravity South -background none -extent 1x9 "$out/${frame}-unfocus-s.png"

    convert "$in" +repage -crop 2x7+11+14       "$out/${frame}-unfocus-se-l.png"
    convert "$in" +repage -crop 7x9+13+12       "$out/${frame}-unfocus-se-r.png"
    convert +append -gravity South -background none "$out/${frame}-unfocus-se-l.png" "$out/${frame}-unfocus-se-r.png" "$out/${frame}-unfocus-se.png"

    convert "$in" +repage -crop 2x2+8+1        "$out/${frame}-sw-inner.png"
    convert "$in" +repage -crop 1x2+10+1       "$out/${frame}-s-inner.png"
    convert "$in" +repage -crop 2x2+11+1       "$out/${frame}-se-inner.png"

    convert "$in" +repage -crop 2x2+8+12       "$out/${frame}-unfocus-sw-inner.png"
    convert "$in" +repage -crop 1x2+10+12      "$out/${frame}-unfocus-s-inner.png"
    convert "$in" +repage -crop 2x2+11+12      "$out/${frame}-unfocus-se-inner.png"
}

function extract_frame
{
    frame="$1"

    in="$out/${frame}-left.png"

    convert "$in" +repage -crop 7x1+1+1   "$out/${frame}-w-l.png"
    convert "$out/${frame}-w-l.png" +repage -gravity West -background none -extent 9x1 "$out/${frame}-w.png"
    convert "$in" +repage -crop 2x1+8+1   "$out/${frame}-w-inner.png"

    convert "$in" +repage -crop 7x1+1+4   "$out/${frame}-unfocus-w-l.png"
    convert "$out/${frame}-unfocus-w-l.png" +repage -gravity West -background none -extent 9x1 "$out/${frame}-unfocus-w.png"
    convert "$in" +repage -crop 7x1+8+4   "$out/${frame}-unfocus-w-inner.png"

    in="$out/${frame}-right.png"
    convert "$in" +repage -crop 7x1+3+1   "$out/${frame}-e-r.png"
    convert "$out/${frame}-e-r.png" +repage -gravity East -background none -extent 9x1 "$out/${frame}-e.png"
    convert "$in" +repage -crop 2x1+1+1   "$out/${frame}-e-inner.png"

    convert "$in" +repage -crop 7x1+3+4   "$out/${frame}-unfocus-e-r.png"
    convert "$out/${frame}-unfocus-e-r.png" +repage -gravity East -background none -extent 9x1 "$out/${frame}-unfocus-e.png"
    convert "$in" +repage -crop 2x1+1+4   "$out/${frame}-unfocus-e-inner.png"

    extract_frame_top_bottom "$frame"
}

in="$dir/971"

convert "$in" -crop 11x6+0+376        "$out/frame-left.png"
convert "$in" -crop 11x6+0+382        "$out/frame-right.png"
convert "$in" -crop 21x54+36+216      "$out/frame-top.png"
convert "$in" -crop 21x22+15+720      "$out/frame-bottom.png"

extract_frame "frame"

in="$dir/971"

convert "$in" -crop 21x54+36+162      "$out/frame-noshadow-top.png"
convert "$in" -crop 21x22+15+654      "$out/frame-noshadow-bottom.png"

extract_frame_top_bottom "frame-noshadow"



in="$dir/971"

# effects

convert "$in" -crop 49x40+83+440   "$out/minmax-glow.png"
convert "$in" -crop 66x40+261+0    "$out/close-glow.png"

# 9  8  9  7
in="$out/minmax-glow.png"
convert "$in" +repage -crop 9x9+0+0        "$out/minmax-glow-nw.png"
convert "$in" +repage -crop 32x9+9+0       "$out/minmax-glow-n.png"
convert "$in" +repage -crop 8x9+41+0       "$out/minmax-glow-ne.png"
convert "$in" +repage -crop 8x24+41+9      "$out/minmax-glow-e.png"
convert "$in" +repage -crop 8x7+41+33      "$out/minmax-glow-se.png"
convert "$in" +repage -crop 32x7+9+33      "$out/minmax-glow-s.png"
convert "$in" +repage -crop 9x7+0+33       "$out/minmax-glow-sw.png"
convert "$in" +repage -crop 9x24+0+9       "$out/minmax-glow-w.png"
convert "$in" +repage -crop 32x24+9+9      "$out/minmax-glow-c.png"

in="$out/minmax-glow-e.png"
convert "$in" +repage -resize 8x21\!       "$out/min-glow-e-resized.png"
in="$out/minmax-glow-w.png"
convert "$in" +repage -resize 9x21\!       "$out/min-glow-w-resized.png"
in="$out/minmax-glow-c.png"
convert "$in" +repage -resize 32x21\!      "$out/min-glow-c-resized.png"

convert +append "$out/minmax-glow-nw.png" "$out/minmax-glow-n.png" "$out/minmax-glow-ne.png" "$out/min-glow-resized-top.png"
convert +append "$out/min-glow-w-resized.png" "$out/min-glow-c-resized.png" "$out/min-glow-e-resized.png" "$out/min-glow-resized-middle.png"
convert +append "$out/minmax-glow-sw.png" "$out/minmax-glow-s.png" "$out/minmax-glow-se.png" "$out/min-glow-resized-bottom.png"
convert -gravity center -append "$out/min-glow-resized-top.png" "$out/min-glow-resized-middle.png" "$out/min-glow-resized-bottom.png" "$out/min-glow-resized.png"



in="$out/minmax-glow-n.png"
convert "$in" +repage -resize 30x9\!       "$out/max-glow-n-resized.png"
in="$out/minmax-glow-s.png"
convert "$in" +repage -resize 30x7\!       "$out/max-glow-s-resized.png"
in="$out/minmax-glow-e.png"
convert "$in" +repage -resize 8x21\!       "$out/max-glow-e-resized.png"
in="$out/minmax-glow-w.png"
convert "$in" +repage -resize 9x21\!       "$out/max-glow-w-resized.png"
in="$out/minmax-glow-c.png"
convert "$in" +repage -resize 30x21\!      "$out/max-glow-c-resized.png"

convert +append "$out/minmax-glow-nw.png" "$out/max-glow-n-resized.png" "$out/minmax-glow-ne.png" "$out/max-glow-resized-top.png"
convert +append "$out/max-glow-w-resized.png" "$out/max-glow-c-resized.png" "$out/max-glow-e-resized.png" "$out/max-glow-resized-middle.png"
convert +append "$out/minmax-glow-sw.png" "$out/max-glow-s-resized.png" "$out/minmax-glow-se.png" "$out/max-glow-resized-bottom.png"
convert -gravity center -append "$out/max-glow-resized-top.png" "$out/max-glow-resized-middle.png" "$out/max-glow-resized-bottom.png" "$out/max-glow-resized.png"







in="$out/close-glow.png"
convert "$in" +repage -crop 9x8+0+0        "$out/close-glow-nw.png"
convert "$in" +repage -crop 49x8+9+0       "$out/close-glow-n.png"
convert "$in" +repage -crop 8x8+58+0       "$out/close-glow-ne.png"
convert "$in" +repage -crop 8x25+58+8      "$out/close-glow-e.png"
convert "$in" +repage -crop 8x7+58+33      "$out/close-glow-se.png"
convert "$in" +repage -crop 49x7+9+33      "$out/close-glow-s.png"
convert "$in" +repage -crop 9x7+0+33       "$out/close-glow-sw.png"
convert "$in" +repage -crop 9x25+0+8       "$out/close-glow-w.png"
convert "$in" +repage -crop 49x25+9+8      "$out/close-glow-c.png"

in="$out/close-glow-n.png"
convert "$in" +repage -resize 51x8\!       "$out/close-glow-n-resized.png"
in="$out/close-glow-s.png"
convert "$in" +repage -resize 51x7\!       "$out/close-glow-s-resized.png"
in="$out/close-glow-e.png"
convert "$in" +repage -resize 8x22\!       "$out/close-glow-e-resized.png"
in="$out/close-glow-w.png"
convert "$in" +repage -resize 9x22\!       "$out/close-glow-w-resized.png"
in="$out/close-glow-c.png"
convert "$in" +repage -resize 51x22\!      "$out/close-glow-c-resized.png"

convert +append "$out/close-glow-nw.png" "$out/close-glow-n-resized.png" "$out/close-glow-ne.png" "$out/close-glow-resized-top.png"
convert +append "$out/close-glow-w-resized.png" "$out/close-glow-c-resized.png" "$out/close-glow-e-resized.png" "$out/close-glow-resized-middle.png"
convert +append "$out/close-glow-sw.png" "$out/close-glow-s-resized.png" "$out/close-glow-se.png" "$out/close-glow-resized-bottom.png"
convert -gravity center -append "$out/close-glow-resized-top.png" "$out/close-glow-resized-middle.png" "$out/close-glow-resized-bottom.png" "$out/close-glow-resized.png"



ln -sfT "$tmpdir" nonredist

echo Done
