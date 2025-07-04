#!/bin/bash
DBPATH=/var/lib/litsearch
mklitentry.sh "$1" >> ${DBPATH}/db.csv
mkiidx.pl ${DBPATH}/db.csv > ${DBPATH}/iidx.csv
