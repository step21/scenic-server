#!/bin/bash
LDIF_FILE="$1"

if [ -z "${LDIF_FILE}" ]; then
  cat <<- EOF
	Usage: $0 file

	file	read operations from 'file'
EOF
  exit 1
fi

if [ ! -f "${LDIF_FILE}" ]; then
  cat <<- EOF
	Error: Can't open file '${LDIF_FILE}'
EOF
  exit 1
fi

for i in `seq 1 5`; do
  docker exec -i `docker-compose ps -q openldap` ldapadd -c < "${LDIF_FILE}"
done
