#!/bin/zsh

# FIXME: We need to regenerate the HTML template. For the menu, mostly.
# FIXME: We also need to generate an index.

autoload -U colors
colors

OUTPUT_DIR=.
typeset -la FILES

function info {
	echo "${fg_bold[green]}-- ${fg_no_bold[white]}$@${reset_color}"
}

function usage {
	echo "usage: $1 [options] <file> [<file> [<file> …] …]"
	echo
	echo "options:"
	echo "  -o <dir>, --output <dir>         Export files to <dir>."
	echo "  -h, --help                       Prints this message."
}

while (( $# > 0 )); do
	case "$1" in
		-h|--help)
			usage "$0"
			exit 0
		;;
		-o|--output|--output-dir)
			[[ -n "$2" ]] || {
				usage "$0"

				exit 1
			}

			OUTPUT_DIR="$2"

			shift 1
		;;
		*)
			echo "unknown parameter: $1" >&2

			exit 2
		;;
	esac

	shift 1
done

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

