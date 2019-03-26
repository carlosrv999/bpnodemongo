#!/bin/bash
datesec=$(date +%s)
sed -i "s/name: mongodb/name: mongo$datesec/" ./servicemongo.yaml
sed -i "s/value: \"mongodb\"/value: \"mongo$datesec\"/" ./deploymentbackend.yaml
kubectl create -f ./deploymentmongo.yaml
kubectl create -f ./servicemongo.yaml
kubectl create -f ./deploymentbackend.yaml
kubectl create -f ./servicebackend.yaml
