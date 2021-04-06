#!/bin/bash

function usage() {

    echo Usage: ./send.sh [PROTOCOL http/mqtt] [MESSAGE event/telemetry] >&2
    exit 13
}

function http_message() {
    local MESSAGE_TYPE="$1"
    local CONTENT="$2"

    curl -i -u $MY_DEVICE@$MY_TENANT:$MY_PWD \
    -H 'Content-Type: application/json' \
    --data-binary "${CONTENT}" \
    http://$HTTP_ADAPTER_IP:8080/$MESSAGE_TYPE

    echo "HTTP ${MESSAGE_TYPE} message sent"
}
# Parameters given Message type and content
function mqtt_message() {
    local MESSAGE_TYPE="$1"
    local CONTENT="$2"

    mosquitto_pub -h $MQTT_ADAPTER_IP \
    -u $MY_DEVICE@$MY_TENANT -P $MY_PWD \
    -t $MESSAGE_TYPE -q 1 -m "${CONTENT}"

    echo "MQTT ${MESSAGE_TYPE} message sent"
}

info=./config.json

test -f $info || (echo "missing config.json" && exit 1)

# Assign variables with values in json
MY_DEVICE=$(jq -r .MY_DEVICE < $info)
MY_TENANT=$(jq -r .MY_TENANT < $info)
MY_PWD=$(jq -r .MY_PWD <$info)
HTTP_ADAPTER_IP=$(jq -r .HTTP_ADAPTER_IP <$info)
MQTT_ADAPTER_IP=$(jq -r .MQTT_ADAPTER_IP <$info)

if [[ "$#" = 2 ]]; then
    # Determine content type per message type given as argument
    case $2 in
        event ) CONTENT='{"alarm":"fire"}';;
        telemetry ) CONTENT='{"temp":5}';;
        * ) usage;;
    esac
    # Execute given argument with CONTENT and MESSAGE TYPE parameters
    case $1 in
        http ) http_message "$2" $CONTENT ;;
        mqtt ) mqtt_message "$2" $CONTENT ;;
        * ) usage;;
    esac
else 
    usage
fi