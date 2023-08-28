#!/usr/bin/env sh

handle_int() {
	exit 1
}

# Extract citation key from file name.
get_key() {
	echo -n "$1" | cut -d '_' -f 1
}

# Extract tags/keywords from file name.
get_tags() {
	echo -n "$1" | cut -s -d '_' -f 2- --output-delimiter=';'
}

# Convert the contents of a PDF file to all-lowercase text and
# remove all non-letter-characters from it.
process_file() {
	pdftotext "$1" - |
		tr [:upper:] [:lower:] |
		tr -s -c a-z '\n' |
		sort -u |
		tr '\n' ' '
}

# Write out a "database" entry of key, tags, absolute path and
# plain text contents of a file ($1) as CSV.
write_entry() {
	FILEPATH=$(readlink -f "$1")
	FILENAME="$(basename "${FILEPATH}" | cut -d '.' -f 1)"
	KEY=$(get_key "${FILENAME}")
	TAGS=$(get_tags "${FILENAME}")
	printf "%s,%s,%s," "${KEY}" "${TAGS}" "${FILEPATH}"
	process_file "$1"
	echo
}

trap handle_int INT

if [ $# -eq 0 ] || [ "$*" = '-' ]; then
	while IFS= read -r F; do
		write_entry "$F"
	done
else
	for F in "$@"; do
		write_entry "$F"
	done
fi
