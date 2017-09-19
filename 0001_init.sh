#!/bin/bash

# http://stackoverflow.com/a/16783253/6461688
if echo '\du' | "${psql[@]}" | cut -d \| -f 1 | grep -qvw "${DB_USER}"; then
    # http://stackoverflow.com/a/8099557/6461688
    "${psql[@]}" <<EOF
DO
\$body\$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM   pg_catalog.pg_user
        WHERE  usename = '${DB_USER}') THEN

        CREATE USER ${DB_USER} WITH ENCRYPTED PASSWORD '${DB_PASS}';
    END IF;
END
\$body\$;
EOF
else
    echo "${DB_USER} already exists"
fi

# If we are in testing mode, allow the user to create database
if echo "${TESTING}" | grep -qvw ''; then
    "${psql[@]}" <<EOF
ALTER USER ${DB_USER} SUPERUSER;
EOF
fi

# http://stackoverflow.com/a/16783253/6461688
if echo '\du' | "${psql[@]}" | cut -d \| -f 1 | grep -qvw "${SECOND_DB_USER}"; then
    # http://stackoverflow.com/a/8099557/6461688
    "${psql[@]}" <<EOF
DO
\$body\$
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM   pg_catalog.pg_user
        WHERE  usename = '${SECOND_DB_USER}') THEN

        CREATE USER ${SECOND_DB_USER} WITH ENCRYPTED PASSWORD '${SECOND_DB_PASS}';
    END IF;
END
\$body\$;
EOF
else
    echo "${SECOND_DB_USER} already exists"
fi



# Create the database if it doesn't exist
# http://stackoverflow.com/a/16783253/6461688
if "${psql[@]}" -lqt | cut -d \| -f 1 | grep -qvw "${DB_NAME}"; then
    "${psql[@]}" <<EOF
CREATE DATABASE ${DB_NAME} WITH OWNER ${DB_USER};

GRANT ALL ON DATABASE ${DB_NAME} TO ${DB_USER};
GRANT CONNECT ON DATABASE ${DB_NAME} TO ${SECOND_DB_USER};
EOF
else
    echo "${DB_NAME} already exists"
fi

dbpsql=( psql -v ON_ERROR_STOP --username ${POSTGRES_USER} --dbname ${DB_NAME} )

# Create the extensions if they don't exist
echo 'CREATE EXTENSION IF NOT EXISTS postgis;' | "${dbpsql[@]}"
echo 'CREATE EXTENSION IF NOT EXISTS postgis_topology;' | "${dbpsql[@]}"
echo 'CREATE EXTENSION IF NOT EXISTS cube;' | "${dbpsql[@]}"
echo 'CREATE EXTENSION IF NOT EXISTS earthdistance;' | "${dbpsql[@]}"
echo 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;' | "${dbpsql[@]}"
# echo 'CREATE EXTENSION IF NOT EXISTS postgresql_fdw;' | "${dbpsql[@]}"
echo 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' | "${dbpsql[@]}"
# echo 'CREATE EXTENSION IF NOT EXISTS postal;'  | "${dbpsql[@]}"

echo '\l' | "${psql[@]}"

echo '\du' | "${psql[@]}"

echo '\dx' | "${dbpsql[@]}"
