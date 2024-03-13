#!/bin/bash

# Generated file names
APP_LIST_CSV="app-list.csv"
APP_OWNERS_LIST_CSV="app-owners-list.csv"

# Get app list into CSV
az ad app list --show-mine --query "[].{displayName:displayName,appId:appId,objectId:id}" | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > $APP_LIST_CSV

# Flat array of apps
FLAT_APPS_ARRAY=$(az ad app list --show-mine --query "[].{objectId:id}" | jq -r '.[].objectId')

# Initialize owners file
echo "appObjectId","displayName","mail","userId","userPrincipalName" > $APP_OWNERS_LIST_CSV

# For each app get the owners
for APP in ${FLAT_APPS_ARRAY}
do
    az ad app owner list --id $APP --query "[].{userId:id,displayName:displayName,userPrincipalName:userPrincipalName,mail:mail}" | jq '.[] += {"appObjectId":$APP}' --arg APP $APP | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $rows[] | @csv' >> $APP_OWNERS_LIST_CSV
done
