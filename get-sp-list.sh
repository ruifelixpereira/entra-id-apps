#!/bin/bash

# Generated file names
SP_LIST_CSV="sp-list.csv"
SP_ASSIGNMENTS_LIST_CSV="sp-assignments-list.csv"

# Get service principals list into CSV
az ad sp list --show-mine --query "[].{principalId:id,displayName:displayName,appId:appId,servicePrincipalType:servicePrincipalType}" | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' > $SP_LIST_CSV

# Flat array of SPs
FLAT_SP_ARRAY=$(az ad sp list --show-mine --query "[].{principalId:id}" | jq -r '.[].principalId')

# Initialize owners file
echo "principalId","principalType","roleDefinitionName","scope" > $SP_ASSIGNMENTS_LIST_CSV

# For each SP get the role assignments
for SP in ${FLAT_SP_ARRAY}
do
    echo "+++++++++++++++++"
    echo $SP
    az role assignment list --assignee $SP --include-inherited --include-groups --query "[].{principalId:principalId,principalType:principalType,roleDefinitionName:roleDefinitionName,scope:scope}" | jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $rows[] | @csv' >> $SP_ASSIGNMENTS_LIST_CSV
    echo "-----------------"
done
