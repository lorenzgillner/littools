#!/usr/bin/env sh

IIDX="$1"

echo "Loading database ..."

perl iidxlookup.pl "${IIDX}" | while read -r DOC; do
	xdg-open "${DOC}"
done

echo "Exited."
