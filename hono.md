Create tenant, add device, add credentials, start receiver, publish telemetry:

1. `kubectl get services`


2. `export REGISTRY_IP=<address from kubectl get services>`
   `export HTTP_ADAPTER_IP=<address from kubectl get services>`
   `export MQTT_ADAPTER_IP=<address from kubectl get services>`

3. create random tenant: `curl -i -X POST http://$REGISTRY_IP:28080/v1/tenants`
   which will be assigned random value. run:
   `export MY_TENANT=<randomed value displayed in shell>`

4. add a device to tenant: `curl -i -X POST http://$REGISTRY_IP:28080/v1/devices/$MY_TENANT`
   run: `export MY_DEVICE=<randomed value displayed in shell>`

5. set a password (replace MY_PWD with your password):
   `export MY_PWD=my-pwd`    
   then run: <code>curl -i -X PUT -H "content-type: application/json" --data-binary '[{
  "type": "hashed-password",
  "auth-id": "'$MY_DEVICE'",
  "secrets": [{
      "pwd-plain": "'$MY_PWD'"
  }]
}]' http://$REGISTRY_IP:28080/v1/credentials/$MY_TENANT/$MY_DEVICE</code>

   it's possible you don't get "ok" response but it should still work 

7. open new terminal but do not close previous terminal so you don't lose env vars, run:
   `export AMQP_NETWORK_IP=<hono dispatch router-ext address from kubectl get services>`
   `export MY_TENANT=<tenant you got earlier>`

8. in folder where hono cli jar is located run (requires jdk 11 or higher):
   `java -jar hono-cli-*-exec.jar --hono.client.host=$AMQP_NETWORK_IP --hono.client.port=15672 --hono.client.username=consumer@HONO --hono.client.password=verysecret --spring.profiles.active=receiver --tenant.id=$MY_TENANT`

9. now that receiver is running you can start sending telemetry data to http adapter. 
   go back to previous terminal and run:
   `curl -i -u $MY_DEVICE@$MY_TENANT:$MY_PWD -H 'Content-Type: application/json' --data-binary '{"temp": 5}' http://$HTTP_ADAPTER_IP:8080/telemetry`
   and you will see sent data in other terminal where hono cli is running

10. you can also send events to http adapter:
   `curl -i -u $MY_DEVICE@$MY_TENANT:$MY_PWD -H 'Content-Type: application/json' --data-binary '{"alarm": "fire"}' http://$HTTP_ADAPTER_IP:8080/event`

11. or telemetry data to MQTT adapter (requires mosquitto_pub command line client):
   `mosquitto_pub -h $MQTT_ADAPTER_IP -u $MY_DEVICE@$MY_TENANT -P $MY_PWD -t telemetry -m '{"temp": 5}'`

12. or events to mqttp adapter: 
   `mosquitto_pub -h $MQTT_ADAPTER_IP -u $MY_DEVICE@$MY_TENANT -P $MY_PWD -t event -q 1 -m '{"alarm": "fire"}'`
