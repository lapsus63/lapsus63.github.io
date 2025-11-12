# Vault Overview

## Documentation

- 

## Overview


## Synchronization script


<p>
<details>
<summary>vault-sync.sh</summary>

```
#!/bin/bash -e

if [ -z "$VAULT_TOKEN" ]
then
  echo "Error: You need to set the VAULT_TOKEN variable. Please log in to https://vault.server.url and export token from your account"
  exit 1
fi

VAULT_URL="https://vault.server.url/v1/apps/app_name/kv/nonprod/data/project-name"
VAULT_PATH="local"
if [ -n "$1" ]
then
  VAULT_PATH=$1
fi

if [ "$VAULT_PATH" == "indus" ] || [ "$VAULT_PATH" == "prod" ]
then
  VAULT_URL="https://vault.server.url/v1/apps/app_name/kv/prod/data/project-name"
fi

curl -s \
    -H "X-Vault-Token: ${VAULT_TOKEN}" \
    -X GET ${VAULT_URL}/${VAULT_PATH} \
    -o ${VAULT_PATH}.json

error_found=`jq 'has("request_id") | not' ${VAULT_PATH}.json`

if [ "$error_found" = "true" ]
then
  echo -n "Error fetching vault data: "
  cat ${VAULT_PATH}.json
  exit 1
fi

mv ${VAULT_PATH}.env ${VAULT_PATH}.env.bak 2> /dev/null || true
jq '.data.data' ${VAULT_PATH}.json | jq -r 'to_entries[]|"\(.key)=\"\(.value)\""' > ${VAULT_PATH}.env
rm ${VAULT_PATH}.json
```

</details>
