#!/bin/bash
appname=$1
replicas=$2
datesec=$(date +%s)
cat > servicemongo.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: $appname
  name: mongo$datesec
  selfLink: /api/v1/namespaces/default/services/mongo-dp$datesec
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: $appname
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
EOF
cat > servicebackend.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: $appname
  name: backendsrv$datesec
  selfLink: /api/v1/namespaces/default/services/backendsrv$datesec
spec:
  externalTrafficPolicy: Cluster
  ports:
  - port: 3000
    protocol: TCP
    targetPort: 3000
  selector:
    app: $appname
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
EOF
cat > deploymentmongo.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: null
  generation: 1
  labels:
    app: $appname
  name: mongodep$datesec
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/mongodep$datesec
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: $appname
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: $appname
    spec:
      containers:
      - image: 100.125.0.23:6443/carlos.ramirezv/mongoalpine:3.6
        imagePullPolicy: Always
        name: mongo
        ports:
        - containerPort: 27017
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status: {}
EOF
cat > deploymentbackend.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: null
  generation: 1
  labels:
    app: $appname
  name: backenddep$datesec
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/backenddep$datesec
spec:
  progressDeadlineSeconds: 600
  replicas: $replicas
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: $appname
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: $appname
    spec:
      containers:
      - image: 100.125.0.23:6443/carlos.ramirezv/$appname:latest
        imagePullPolicy: Always
        name: backend
        env:
        - name: MONGODB_HOST
          value: "mongo$datesec"
        - name: NM_APP_NAME
          value: "$appname"
        ports:
        - containerPort: 3000
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status: {}
EOF
