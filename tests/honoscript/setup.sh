#!/bin/bash

declare -i  TIME=20
declare -i  INSTALL_TIME=200

function die() {
    echo "$@" >&2
    exit 13
}

function check_hono_cli() {
    echo '50d6699fa7893af7bfd3cc86df7e5e5488a255a2fbe35c154b23221f88abf134  hono-cli-1.9.0-exec.jar' | sha256sum -c --status
}

function hono_cli_install() {
    check_hono_cli && return 0

    curl -m $INSTALL_TIME -o hono-cli-1.9.0-exec.jar https://download.eclipse.org/hono/hono-cli-1.9.0-exec.jar || return 1

    check_hono_cli
}

hono_cli_install || die "Hono cli install failure"

which jq &> /dev/null || die "You're missing jq"
which curl &> /dev/null || die "Can't curl"
which pwgen &> /dev/null || die "Needs pwgen"
which mosquitto_pub &> /dev/null || die "Needs mosquitto-clients"


DNS_LABEL=$(timeout $TIME kubectl get service ambassador -o json | jq -r .metadata.annotations.\"service.beta.kubernetes.io/azure-dns-label-name\")
MQTT_PORT=1883
MQTT_SECURE_PORT=8883
KAFKA_PORT=9092
#KAFKA_TRUSTSTORE_PATH=./truststore.jks
#kubectl get secrets hono-kafka-jks --template="{{index .data \"kafka.truststore.jks\" | base64decode}}" -n default > $KAFKA_TRUSTSTORE_PATH

DOMAIN_NAME=${DNS_LABEL}".westeurope.cloudapp.azure.com"

MY_TENANT=$(curl -m $TIME -X POST -H "content-type: application/json" https://${DOMAIN_NAME}/registry/v1/tenants --data-binary '{
  "ext": {
    "messaging-type": "kafka" 
  }
}' 2> /dev/null | jq -r .id )
: ${MY_TENANT:?'Your tenant has moved out. Could not set MY_TENANT'}
test ${#MY_TENANT} = 36 || die "MY_TENANT is the wrong size. Does not have 36 characters"

MY_DEVICE=$(curl -m $TIME -X POST https://${DOMAIN_NAME}/registry/v1/devices/$MY_TENANT 2> /dev/null | jq -r .id)
: ${MY_DEVICE:?'Your device has left the building. Could not set MY_DEVICE'}
test ${#MY_DEVICE} = 36 || die "MY_DEVICE doesn't fit. Does not have 36 characters"

MY_PWD=$(timeout $TIME pwgen -s 15 1)
: ${MY_PWD:?'Password generation failed'}
test ${#MY_PWD} = 15 || die "Your password does not have 15 characters"

body=$(cat <<BODY
[
    {
        "type":"hashed-password",
        "auth-id": "${MY_DEVICE}",
        "secrets": [
            {
                "pwd-plain": "${MY_PWD}"
            }
        ]
    }
]
BODY
)

curl -m $TIME -f -X PUT \
    -H 'content-type: application/json' \
    --data-binary "$body" \
    https://${DOMAIN_NAME}/registry/v1/credentials/$MY_TENANT/$MY_DEVICE || die "could not set password so curling failed"


#ADD "HTTP_ADAPTER_IP": "${HTTP_ADAPTER_IP}" when needed for HTTP messaging
cat > config.json <<JSON
{
    "DOMAIN_NAME": "${DOMAIN_NAME}",
    "MQTT_PORT": "${MQTT_PORT}",
    "MQTT_SECURE_PORT": "${MQTT_SECURE_PORT}",
    "KAFKA_PORT": "${KAFKA_PORT}",
    "MY_TENANT": "${MY_TENANT}",
    "MY_DEVICE": "${MY_DEVICE}",
    "MY_PWD": "${MY_PWD}",
    "KAFKA_TRUSTSTORE_PATH": "${KAFKA_TRUSTSTORE_PATH}"
}
JSON
