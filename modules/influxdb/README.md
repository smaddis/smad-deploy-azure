### Upgrading to 2.0.0 see:

https://github.com/bitnami/charts/tree/137854312b3ba5c40f7224b7d752b829e6b1fdcf/bitnami/influxdb#upgrading

# Use Influx Cli

### Get inside pod:

run `$ kubectl get pods` to get pod NAME

run `$ kubectl exec -it <$POD NAME> -- /bin/bash`

ie:

        `$ kubectl exec -it influxdb-85bcf65585-fnmq2  -- /bin/bash`

### Start influx inside pod with

`$ influx -password <$PWD> -username <$USERNAME> -database <$DATABASE NAME>`

ie: 

        `$ influx -password root -username root -database monitoring_data`