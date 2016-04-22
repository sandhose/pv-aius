#!/bin/sh

FILE="$1"

[ "${FILE%.md}" != "${FILE}" ] || {
	echo "First parameter is not a markdown file." >&2
	exit 1
}

FILE="${FILE%.md}"

: ${OUTPUT_DIR:=$HOME/}

# FIXME: We need to regenerate the HTML template. For the menu, mostly.
# FIXME: We also need to generate an index.

echo "-- Generating ${FILE}.html"
pandoc --template template.html ${FILE}.md -o $OUTPUT_DIR/${FILE}.html -N

echo "-- Generating ${FILE}.pdf"
pandoc ${FILE}.md --latex-engine=xelatex -H header.tex -o $OUTPUT_DIR/${FILE}.pdf -N -V documentclass=article --toc

