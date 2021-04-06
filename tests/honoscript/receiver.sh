#!/bin/bash

info=./config.json

test -f $info || exit 1

AMQP_NETWORK_IP=$(jq -r .AMQP_NETWORK_IP < $info)
MY_TENANT=$(jq -r .MY_TENANT < $info)

java -jar hono-cli-1.6.0-exec.jar \
--hono.client.host=$AMQP_NETWORK_IP \
--hono.client.port=15672 \
--hono.client.username=consumer@HONO \
--hono.client.password=verysecret \
--spring.profiles.active=receiver \
--tenant.id=$MY_TENANT
