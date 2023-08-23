#!/bin/bash

TAG_DELIM='#'

function handle_int() {
	exit 1
}

# Extract citation key from file name.
function get_key() {
	echo -n "${1%.*}" | cut -d '_' -f 1
}

# Extract tags/keywords from file name.
function get_tags() {
	if [[ "$1" =~ .+(_[a-z]+)+\..+ ]]; then
		echo -n "${1%.*}" | cut -d '_' -f 2- --output-delimiter=${TAG_DELIM}
	fi
}

# Convert the contents of a PDF file to all-lowercase text and
# remove all non-letter-characters from it.
function process_file() {
	pdf2txt "$1" \
	| tr '[:cntrl:][:punct:][:digit:][:space:]' ' ' \
	| tr -s ' ' \
	| tr '[:upper:]' '[:lower:]' \
	| tr -d -c '[:alpha:] '
}

# Write out a "database" entry of key, tags, absolute path and
# plain text contents of a file ($1) as CSV.
function write_entry() {
	FILE=$(basename "$1")
	KEY=$(get_key "${FILE}")
	TAGS=$(get_tags "${FILE}")
	FPATH=$(readlink -f "$1")
	printf "%s,%s,%s," "${KEY}" "${TAGS}" "${FPATH}"
	process_file "$1"
	echo
}	

trap handle_int INT

if [ $# -eq 0 ] || [ "$*" = '-' ]; then
	while IFS= read -r F; do
		write_entry "$F"
	done
else
	for F in $@; do
		write_entry "$F"
	done
fi
