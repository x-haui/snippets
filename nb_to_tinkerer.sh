#!/bin/bash
# converts the *txt files inside nanoblogger's
# data directory into a format known by Tinkerer
TINKERBASE=~/tinkerblog
BLOG_URL=http:\/\/MODIFY.ME

for arg; do
	TITLE=$(grep -m1 ^TITLE: "$arg" | sed 's#TITLE: ##')
	TITLELEN=$(wc -c <<< "$TITLE" | cut -d " " -f 1)
	FILENAME=$(sed -e 's/./\l&/g;s#[^a-zA-Z0-9_]#_#g' <<< "$TITLE").rst
	DATE=$(date -d  "$(grep -m1 ^DATE: "$arg" | sed 's#DATE: ##')" +%Y/%m/%d)
	BODY_START=$(grep -m1 -n BODY: "$arg" | cut -d : -f 1)
	LINES=$(wc -l "$arg" | awk '{print $1}')
	TOREAD=$((LINES - BODY_START))
	DIR="$TINKERBASE/$DATE"
	FILE="$DIR/$FILENAME"
	CATEGORIES="$(grep "$arg" master.db | cut -d ">" -f 2 | tr ',' '\n' | while read l; do head -n 1 cat_${l}.db ; done | tr '\n' ', ' | sed 's#,$##')"

	#newest article must be on top
	TAIL=$(wc -l "$TINKERBASE"/master.rst | cut -d " " -f 1)
	TOP=$(grep -m 1 -n :maxdepth: "$TINKERBASE"/master.rst | cut -d : -f 1)
	
	head -n "$TOP" "$TINKERBASE"/master.rst > "$TINKERBASE"/_master.rst
	echo "" >> "$TINKERBASE"/_master.rst
	echo "   $DATE/${FILENAME%%.rst}" >> "$TINKERBASE"/_master.rst
	tail -n $((TAIL-TOP)) "$TINKERBASE"/master.rst |  sed '/^$/d' >> "$TINKERBASE"/_master.rst
	mv "$TINKERBASE"/_master.rst "$TINKERBASE"/master.rst


	mkdir -p "$DIR"
	echo "$TITLE" > "$FILE"
	perl -e "print \"=\"x$TITLELEN" >> "$FILE"
	echo -e "\n\n" >> "$FILE"

	tail -n "$TOREAD" "$arg" | sed "s#%base_url%#$BLOG_URL#g" | pandoc --from=html --to=rst >> "$FILE"
	echo "" >> "$FILE"
	echo ".. author:: default" >> "$FILE"
	echo ".. categories:: $CATEGORIES" >> "$FILE"
	echo ".. tags:: $CATEGORIES" >> "$FILE"

done


