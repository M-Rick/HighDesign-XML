#! /bin/sh

# Convert color palettes to HighDesign XML
# Aymeric GILLAIZEAU

for f in "$@"
do

# Scribus XML to HighDesign XML
if grep -q 'SCRIBUSCOLORS' "$f" ; then
NAME=$(basename -- "$f") ; NAME="${NAME%.*}" ; NAME=$( echo "$NAME" | sed 's/_/ /g'); \
exec cat "$f" | sed '/^<\!--/,/^-->/{/^<\!--/!{/^-->/!d;};}' | sed '/<\!--/d' | sed '/-->/d' | sed '1a\
\<ColourPalette Handle="A" Tag="standard_palette" Editable="True">
'  | \
sed 's#<SCRIBUSCOLORS Name="#<ColourPalette AppSignature="0" ClassID="0" Name="#g' | \
sed 's#Name="\(.*\)" >#Name="\1" Location="0" FileURL="" FileType="0" Version="1.000000" ModDate_From1970="0.000000" Active="False"/>\
	<Colors>#g' | \
sed 's/<COLOR RGB="#/<Color Index="0" Value="\&amp;h00/' | \
sed 's#" NAME=".*" />#" PenWeightBitValue="0" PenWeightIndex="0"/>#g' | \
sed 's#</SCRIBUSCOLORS>#</Colors>#g' | \
sed '$a\
\</ColourPalette>' > ~/Desktop/"$NAME"\ \(HighDesign\).xml
# Gimp/Inkscape GPL to HighDesign XML
elif grep -q 'GIMP Palette' "$f" ; then
FILE=$(basename -- "$f") ; FILE="${NAME%.*}" ; FILE=$( echo "$FILE" | sed 's/_/ /g'); \
NAME=$(cat "$f" | sed -n -e 's/^.*Name: //p'); \
cat "$f" | sed -En 's/[^0-9]*([0-9]{1,})[^0-9]*/\1 /gp' | sed 's/ /\;/' | sed 's/  /\;/' | sed 's/ /\;/' | sed 's/ /\@/' | \
sed 's/\@.*//g' | \
while IFS=';' read -a n ; do
    printf '%02X;' "${n[@]}"
    echo
done | sed 's/;$//' | \
sed 's/;//g' | \
sed 's#^#<Color Index="0" Value="\&amp;h00#' | \
sed 's#$#" PenWeightBitValue="0" PenWeightIndex="0"/>#g' | \
sed '1i\
<?xml version="1.0" encoding="UTF-8"?>
' | sed '1a\
<ColourPalette Handle="A" Tag="standard_palette" Editable="True">
'  | sed '2a\
<ColourPalette AppSignature="0" ClassID="0" Name="'"$NAME"'" Location="0" FileURL="" FileType="0" Version="1.000000" ModDate_From1970="0.000000" Active="True"/>
'  | \
sed '3a\
<Colors>
'  | sed '$a\
\</Colors>' | sed '$a\
\</ColourPalette>
' > ~/Desktop/"$NAME"\ \(HighDesign\).xml
# LibreOffice XML SOC to HighDesign XML
elif grep -q 'openoffice.org\|ooo:color-table' "$f" ; then
NAME=$(basename -- "$f") ; NAME="${NAME%.*}" ; NAME=$( echo "$NAME" | sed 's/_/ /g'); \
cat "$f" | sed 's/^.*draw:color="\(.*\)/@"\1/' | sed 's/draw:name=".*//' | \
sed 's#@"\(.*\)/>#@"\1#' | sed 's/ //' | sed '/^@"#/!d' | sed '1i\
\<?xml version="1.0" encoding="UTF-8"?>
' | sed '1a\
\<ColourPalette Handle="A" Tag="standard_palette" Editable="True">
'  | sed '2a\
<ColourPalette AppSignature="0" ClassID="0" Name="'"$NAME"'" Location="0" FileURL="" FileType="0" Version="1.000000" ModDate_From1970="0.000000" Active="True"/>
'  | sed '3a\
<Colors>
' | sed '$a\
\</Colors>' | sed '$a\
\</ColourPalette>
' | sed 's#@"\(.*\)"#@"\1" PenWeightBitValue="0" PenWeightIndex="0"/>#' | \
sed 's/@"#/<Color Index="0" Value="\&amp;h00/' > ~/Desktop/"$NAME"\ \(HighDesign\).xml
fi

done
