---
title: How to Install Redis to Kubernetes Cluster
tags: ["database", "fullstack", "kubernetes"]
date: "2023-06-23T11:29:00.000Z"
---

Follow these steps to achieve desired functionality like previously shown in 
[**mysql-deployment**](https://github.com/KlosStepan/DOKS-tutorial/tree/main/mysql-deployment).  
Used image of Redis https://hub.docker.com/_/redis has to be wrapped in the similar manner and exposed as `redis-service:6379`.  

This tutorial shows cluster overview by [**Lens**](https://k8slens.dev/desktop.html) (via kubectl) rather than raw [**kubectl**](https://kubernetes.io/docs/tasks/tools/) CLI.
<p align="center">
  <img src="redis-deployment.png" alt="Installed Redis in K8s Cluster "/>
</p>

## 0. Generate base64 password & apply Kubernetes Secret.
Generate base64 password and place it into redis-secret file.  
<ins>Files/scripts</ins>

- Script `0-encode-base64.zsh`.
```zsh
#!/usr/bin/zsh
echo -n $1 | base64
```
- Kubernetes Secret `0-redis-secret.yaml`.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redis-secrets
type: Opaque
data:
  REDIS_PASSWORD: cGFzc3dvcmQ=
```
<ins>Steps</ins>  
1. Encode password via script to put into Kubernetes Secret.
```zsh
chmod u+x 0-encode-base64.zsh 
zsh 0-encode-base64.zsh password 
cGFzc3dvcmQ=
```
2. Put output base64 encoded password into secret and apply it.
```
kubectl apply -f 0-redis-secret.yaml 
secret/redis-secrets created
```
## I. Create PV & and make PVC on it.
<ins>Files/scripts</ins>
- Kubernetes Persistent Volume and Persistent Volume Claim `1-pv-pvc-redis.yaml`.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 6Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/redis"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 6Gi
  storageClassName: do-block-storage
```
<ins>Steps</ins>  
1. Create PV & PVC.
```zsh
kubectl apply -f 1-pv-pvc-redis.yaml  
persistentvolume/redis-pv created
persistentvolumeclaim/redis-pvc created
```
<ins>Result in Lens</ins> 
<p align="center">
  <img src="redis-1.png" alt="Redis PV & PVC running"/>
</p>

## II. Create Service (internal) & Deployment.  
<ins>Files/scripts</ins>  

- Internal Service and Deployment  `2-deployment-redis.yaml`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  ports:
  - port: 6379
  selector:
    app: redis
  clusterIP: None
---
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis
        command: ["redis-server"]
        args:
        - "--save"
        - "20"
        - "1"
        - "--loglevel"
        - "warning"
        - "--requirepass"
        - "cGFzc3dvcmQ="
        #args:
        #  - "--requirepass"
        #  - "${REDIS_PASSWORD}"
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
      volumes:
      - name: redis-data
        persistentVolumeClaim:
          claimName: redis-pvc
```
<ins>Steps</ins>
```zsh
kubectl apply -f 2-deployment-redis.yaml 
service/redis created
deployment/redis created
```
<ins>Result in Lens</ins>
<p align="center">
  <img src="redis-2.png" alt="Redis Service(internal) & Deployment running"/>
</p>

## III. Create Service (exposed on :6379) + link the internal one.
<ins>Files/scripts</ins>  
- Accessible Service `3-service-redis.yaml`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
```
<ins>Steps</ins>
```zsh
kubectl apply -f 3-service-redis.yaml 
service/redis-service created  
```
<ins>Result in Lens</ins>
<p align="center">
  <img src="redis-3.png" alt="Redis Public Service running"/>
</p>

## IV. Your redis-service is live now!
Redis server is then accessible on redis-service i.e. redis-service:6379. There, however, have to be protocol and password like `tcp://redis-service:6379?auth=PASSWD` in your app deployment/setup.
___
## Tips on how to use Redis! 
Both `MySQL` and `Redis` are were tested on multireplica deployment of our LAMP application that we previously programmed. We tried to port basic LAMP stack into Kubernetes to be cloud ready.    
<ins>Visualization on how containers share databases</ins>  
Both have persistent storage. Database for obvious purposes, Redis for keeping sessions live in case of reboots or death of containers during lifecycle.  
<p align="center">
  <img src="K8s_SwimmPair.png" alt="MySQL Service + Redis Service"/>
</p>
They run at usable for other applications:

- mysql-service:3306,
- redis-service:6379.

For the PHP app, however, we have to change php.ini to adjust PHP for using Redis for session handling as follows:
```php
session.save_handler: 'redis'
session.save_path: 'tcp://redis:6379?auth=aGVzbG8='
```
Our used docker image [thecodingmachine/php:7.2-v4-apache](https://github.com/thecodingmachine/docker-images-php) has a specific way how to override these params via [ENV VARIABLES](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html). Both `docker-compose` and `Kubernetes Deployment` have same notation for setting environment variables.
```yaml
    environment:
      PHP_INI_SESSION__SAVE_HANDLER: 'redis'
      PHP_INI_SESSION__SAVE_PATH: 'tcp://redis:6379?auth=aGVzbG8='
```
After that we should be able to call `phpinfo();` to see `session.save_handler` and `session.save_path` set up as mentioned above.  

Happy using!