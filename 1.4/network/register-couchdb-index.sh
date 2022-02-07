#!/bin/sh
# You need couchdb_index_registration.json in the same directory.
# Usage:
# ./register-couchdb-index.sh http://localhost:5984/

scriptdir=$(cd $(dirname $0); pwd)

if test -n "$1"; then
	COUCHDB_URL="$1"
else
	echo "Please specify Couch DB URL (e.g., http://localhost:5984/)"
	exit 1
fi
JSONPREFIX=$scriptdir/couchdb-index-registration-

echo $COUCHDB_URL
for JSONFILE in ${JSONPREFIX}*.json; do
	echo $JSONFILE
	curl -X POST -H "Content-Type: application/json"  -d @${JSONFILE} ${COUCHDB_URL}/mufgslachannel/_index
done
