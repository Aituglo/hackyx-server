#!/bin/bash

sleep 10

COUCHDB=http://couchdb:5984/
AUTH=$COUCHDB_USER:$COUCHDB_PASSWORD

if [ -z "$HACKYX_PASSWORD" ]; then
    HACKYX_PASSWORD=$(openssl rand -hex 32)
    echo "[HACKYX] Created following password for user hackyx: $HACKYX_PASSWORD"
fi

# create the _users db
curl -X PUT $COUCHDB"_users" -u $AUTH -s > /dev/null

# create the hackyx user
curl -X PUT -X PUT $COUCHDB"/_users/org.couchdb.user:hackyx" -u $AUTH \
     -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -d '{"name": "hackyx", "password": "'$HACKYX_PASSWORD'", "roles": [], "type": "user"}' -s > /dev/null

# create a new database called bbf
curl -X PUT $COUCHDB"hackyx" -u $AUTH -s > /dev/null

# grant access rights to the new database
curl -X PUT $COUCHDB"hackyx/_security" -u $AUTH -d "{\"admins\": {\"names\": [],\"roles\": []}, \"members\": {\"names\": [\"hackyx\"],\"roles\": []}}" -s > /dev/null

# push hackyx views
curl -X PUT $COUCHDB"hackyx/_design/hackyx" -u $AUTH -H "Content-Type: application/json" -d @/tmp/views.json -s > /dev/null

# enable CORS
curl -X PUT $COUCHDB"_node/_local/_config/httpd/enable_cors" -u $AUTH -d '"true"' -s > /dev/null

# allow origin from dashboard on https://hackyx.me
curl -X PUT $COUCHDB"_node/_local/_config/cors/origins" -u $AUTH -d '"*"' -s > /dev/null
curl -X PUT $COUCHDB"_node/_local/_config/cors/credentials" -u $AUTH -d '"true"' -s > /dev/null

echo "[HACKYX] Initialization complete"
