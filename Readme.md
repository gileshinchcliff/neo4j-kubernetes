## Running Clustered Neo4j on Kubernetes.

#### Cluster the Nodes

Once you've decided how many nodes you want to have then first create your services for each of your nodes to join the cluster like so.

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    name: neo4j-<cluster-number>
  name: neo4j-<cluster-number>
spec:
  ports:
    -
      name: cluster
      port: 5001
      targetPort: 5001
    -
      name: transaction
      port: 6001
      targetPort: 6001
  selector:
    name: neo4j-<cluster-number>
```

This will mean that each pod will have their own static ip.

Then from there you can spin up your pods. 

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  labels:
    app: neo4j-<cluster-number>
  name: neo4j-<cluster-number>
spec:
  replicas: 1
  selector:
    name: neo4j-<cluster-number>
  template:
    metadata:
      labels:
        name: neo4j-<cluster-number>
        app: neo4j-<cluster-number>
    spec:
      containers:
        -
          imagePullPolicy: Always
          image: neo4j:3.0.2-enterprise
          name: neo4j-<cluster-number>
          resources:
            limits:
              memory: "2G"
              cpu: "500m"
          ports:
          - containerPort: 7474
            name: "http"
          - containerPort: 5001
            name: "cluster"
          - containerPort: 6001
            name: "transaction"
          env:
          - name: "NEO4J_dbms_mode"
            value: "HA"
          - name: NEO4J_ha_host_coordination
            value: 0.0.0.0:5001
          - name: NEO4J_ha_host_data
            value: neo4j-1:6001
          - name: "NEO4J_HA_ADDRESS"
            value: "0.0.0.0"
          - name: "NEO4J_ha_serverId"
            value: "<cluster-number>"
          - name: "NEO4J_ha_initialHosts"
            value: "neo4j-1:5001,neo4j-2:5001,neo4j-3:5001"
      restartPolicy: Always
```


Note the environment variables:

* `NEO4J_HA_ADDRESS` must be 0.0.0.0 to allow the pods ip's in as they can be any ip. 
* `NEO4J_ha_initialHosts` a comma separated list of your nodes using the service ips, or dns names if you have them.
* `NEO4J_ha_serverId` id of a server must be unique within a cluster.
* `NEO4J_ha_host_coordination` same as `NEO4J_HA_ADDRESS` but with the port added.
