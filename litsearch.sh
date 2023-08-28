#!/usr/bin/env sh

IIDX=$1

echo "Loading database ..."

perl iidxlookup.pl "${IIDX}" | while read -r DOC
do
    xdg-open "${DOC}" 2>/dev/null
done

echo "Exited."