#!/bin/bash
kubectl create -f ./deploymentmongo.yaml
kubectl create -f ./servicemongo.yaml
kubectl create -f ./deploymentbackend.yaml
kubectl create -f ./servicebackend.yaml
