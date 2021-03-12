# Hono tester

These scripts create tenant and devices for testing Hono messages.
Used for testing Hono instances running in K8S cluster.

**Requires:**

- jdk 11 or higher
- jq
- curl
- pwgen
- mosquitto-clients

Run scripts in the same directory!

1. Get (Azure) credentials to local kubeconfig with 

    `az aks get-credentials --resource-group <resource-group-name> --name <k8s-cluster-name>`
2. run `./setup.sh`
3. Run `./receiver.sh`
4. Open a new terminal screen for message sending. Leave `./receiver.sh` running
5. Send message with following options: `./send.sh [PROTOCOL] [MESSAGE]`

**Options:** 

Protocol options: `mqtt` or `http` 

Message types: `event` or `telemetry`

**Example:**
- Send HTTP event message `./send.sh http event`
- Send MQTT telemetry message `./send.sh mqtt telemetry`
