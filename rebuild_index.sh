#!/bin/bash
DBPATH=/var/lib/litsearch
mklitdb.sh . > ${DBPATH}/db.csv
mkiidx.pl ${DBPATH}/db.csv > ${DBPATH}/iidx.csv
