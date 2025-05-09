#!/bin/bash

docker login

docker build -t nginx-app .

docker tag nginx-app nowsiejko/nginx-app:1.0

docker push nowsiejko/nginx-app:1.0

kubectl apply -f deployment.yaml

kubectl apply -f service.yaml

sleep 5

kubectl get deployment nginx-deployment

kubectl get pods -l app=nginx-personal

kubectl get service nginx-service

RESPONSE=$(curl http://localhost)
echo $RESPONSE

kubectl scale deployment nginx-deployment --replicas=5

sleep 5

kubectl get deployment nginx-deployment


kubectl get pods -l app=nginx-personal