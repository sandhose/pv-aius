#!/bin/zsh

: ${OUTPUT_DIR:=./}

# FIXME: We need to regenerate the HTML template. For the menu, mostly.
# FIXME: We also need to generate an index.

# Needed because of unicode…
function block {
	N="$1" # block size
	S="$2" # string

	# Relies on a GNU extension of wc
	size="$(echo "$S" | wc -L)"
	echo -n "$S"

	for i in {1..$(($N - $size))}; do
		echo -n " "
	done
}

{
	echo
	printf "%-120s %-120s %-120s\n" "Document" "pdf" "man"

	for j in {1..3}; do
		S=""
		for i in {1..120}; do
			S="${S}-"
		done
		(( $j < 3 )) && echo -n "$S "
	done
	echo

	for i in *.md; do
		f=${i%.md}
		block 121 "[${f}](${f}.html)"
		block 121 "[pdf]($f.pdf)"
		block 121 "[man]($f.7)"
		echo
	done
	echo
} > .tmp.md

echo "-- Generating index.html"
pandoc --template template.html .tmp.md -o $OUTPUT_DIR/index.html -N \
	--css=https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css \
	--css=pv.css --toc

rm .tmp.md

