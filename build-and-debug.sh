#!/bin/bash
set -euo pipefail

# Get public IP address
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Detected public IP: $PUBLIC_IP"

# Generate a random 6-character alphanumeric string
RANDOM_ID=$(tr -dc 'a-z0-9' </dev/urandom | head -c 6 || true)
INSTANCE_IDENTIFIER="mygitspace-phdeku-${RANDOM_ID}"
CONTAINER_NAME="gitspace-harness-mygitspace-phdeku-${RANDOM_ID}"

echo "Generated Instance Identifier: $INSTANCE_IDENTIFIER"
echo "Generated Container Name: $CONTAINER_NAME"

echo "Checking gitspace-agent health..."
health_response=$(curl --connect-timeout 10 --retry 3 --retry-delay 1 \
  -X GET "http://${PUBLIC_IP}:8083/status" \
  -o /dev/null -s -w "%{http_code}")

echo "Health Response Code: $health_response"

if [[ "$health_response" != "200" ]]; then
  echo "❌ Gitspace agent is not healthy. Exiting."
  exit 1
fi

echo "Gitspace agent is healthy"

echo "Starting Gitspace..."
start_response=$(curl --connect-timeout 10 --retry 3 --retry-delay 1 \
  -X POST "http://${PUBLIC_IP}:8083/gitspace-agent/api/v1/gitspaces/start" \
  -H "Content-Type: application/json" \
  -d '{
    "manager_base_url":"https://151c-125-19-67-142.ngrok-free.app/api/v1/accounts/kmpySmUISimoRrJL6NL73w/orgs/default/projects/Test",
    "cde_gateway_url":"",
    "account_identifier":"kmpySmUISimoRrJL6NL73w",
    "gitspace_config":{
      "identifier":"mygitspace-phdeku",
      "instance_identifier":"'"$INSTANCE_IDENTIFIER"'",
      "space_id":3,
      "user_uid":"harness",
      "ide":"vs_code_web",
      "access_key":"Harness@123",
      "access_type":"user_credentials",
      "code_repo_config":{
        "name":"gitness",
        "url":"https://git0.harness.io/l7B_kbSEQD2wjrM7PShm5w/PROD/Harness_Commons/gitness.git",
        "branch":"devcontainer",
        "username":"",
        "email":"",
        "password":"",
        "repo_type":"unknown"
      }
    },
    "devcontainer_specification":{
      "remoteUser": "root",
      "image":"mcr.microsoft.com/devcontainers/go:1-1.23",
      "postCreateCommand":"sh scripts/install_codex.sh | tee exec.log",
      "postStartCommand":"./scripts/fix_lint.sh",
      "containerEnv": {
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      }
    },
    "default_base_image":"mcr.microsoft.com/devcontainers/base:dev-ubuntu-24.04",
    "port_mappings":{"8089":8089},
    "container_name":"'"$CONTAINER_NAME"'",
    "image_proxy_enabled":false,
    "proxy":{"http_proxy_url":"","https_proxy_url":"","no_proxy_url":""},
    "log_key":"LogKey:gitspaceConfigID:mygitspace-phdeku"
  }' \
  -o /dev/null -s -w "%{http_code}")

echo "API Response Code: $start_response"

URL="http://${PUBLIC_IP}:8089/?folder=/root/gitness"

if [[ "$start_response" == "202" ]]; then
  echo "Gitspace started successfully ✅"
  echo "Open your CDE here $URL"
else
  echo "Gitspace start request failed ❌"
  exit 1
fi

outputFilePath="$DRONE_OUTPUT"

key=CDE
value=$URL

echo "$key=$value" > "$outputFilePath"
