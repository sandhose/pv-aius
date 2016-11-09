#!/bin/zsh

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
		-*)
			echo "unknown parameter: $1" >&2

			exit 2
		;;
		*)
			FILES+=("$1")
		;;
	esac

	shift 1
done

if (( ${#FILES[@]} == 0 )); then
	usage
	exit 1
fi

for FILE in "${FILES[@]}"; do
	FILE="${FILE%.md}"

	info "Generating ${FILE}.html"
	pandoc ${FILE}.md -o $OUTPUT_DIR/${FILE}.html \
		--template template.html -N \
		--css=https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css \
		--css=pv.css --toc

	info "Generating ${FILE}.7"
	pandoc ${FILE}.md -o $OUTPUT_DIR/${FILE}.7 -s --toc

	info "Generating ${FILE}.docx"
	pandoc ${FILE}.md -o $OUTPUT_DIR/${FILE}.docx -s --toc

	info "Generating ${FILE}.odt"
	pandoc ${FILE}.md -o $OUTPUT_DIR/${FILE}.odt -s --toc

	info "Generating ${FILE}.epub"
	pandoc ${FILE}.md -o $OUTPUT_DIR/${FILE}.epub -s --toc

	info "Generating ${FILE}.pdf"
	pandoc ${FILE}.md -o $OUTPUT_DIR/${FILE}.pdf \
		--latex-engine=xelatex \
		-H header.tex \
		--template template.tex \
		-N -V documentclass=article --toc
done

