#!/bin/bash

echo "==== Wdrażanie aplikacji z trzema serwisami ===="

echo "Budowanie obrazu mikroserwisu A..."
docker build -t nowsiejko/service-a:latest -f Dockerfile --build-arg APP_NAME=service_a.py .
docker push nowsiejko/service-a:latest

echo "Budowanie obrazu mikroserwisu B..."
docker build -t nowsiejko/service-b:latest -f Dockerfile --build-arg APP_NAME=service_b.py .
docker push nowsiejko/service-b:latest

echo "1. Wdrażanie bazy danych PostgreSQL..."
kubectl apply -f database.yaml
echo "Czekam na uruchomienie bazy danych..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=60s || true


echo "2. Wdrażanie mikroserwisu B..."
kubectl apply -f service_b.yaml
echo "Czekam na uruchomienie mikroserwisu B..."
kubectl wait --for=condition=ready pod -l app=service-b --timeout=60s || true


echo "3. Wdrażanie mikroserwisu A..."
kubectl apply -f service_a.yaml
echo "Czekam na uruchomienie mikroserwisu A..."
kubectl wait --for=condition=available deployment/service-a --timeout=60s || true


echo -e "\n==== Podsumowanie wdrożenia ===="
echo "Sprawdzanie statusu podów:"
kubectl get pods

echo -e "\nSprawdzanie statusu serwisów:"
kubectl get services

echo -e "\nSprawdzanie statusu persistent volumes:"
kubectl get pv,pvc


echo -e "\nTestowanie mikroserwisu A przez port-forward:"
kubectl port-forward service/service-a 8080:80 > /dev/null 2>&1 &
PORT_FORWARD_PID=$!

sleep 5

echo "Testowanie komunikacji mikroserwisu A z mikroserwisem B:"
RESPONSE=$(curl -s http://localhost:8080)
echo "Odpowiedź z mikroserwisu A: $RESPONSE"

kill $PORT_FORWARD_PID 2>/dev/null


echo -e "\nTestowanie komunikacji mikroserwisu B z bazą danych:"
kubectl port-forward service/service-b 8081:5000 > /dev/null 2>&1 &
PORT_FORWARD_B_PID=$!

sleep 3

B_RESPONSE=$(curl -s http://localhost:8081)
echo "Odpowiedź z mikroserwisu B: $B_RESPONSE"


if [[ "$B_RESPONSE" == *"z bazy danych"* ]]; then
  echo "Mikroserwis B poprawnie komunikuje się z bazą danych"
else
  echo "Mikroserwis B nie komunikuje się z bazą danych"
  echo "Logi mikroserwisu B:"
  kubectl logs -l app=service-b --tail=20
fi

kill $PORT_FORWARD_B_PID 2>/dev/null
wait $PORT_FORWARD_B_PID 2>/dev/null || true



echo "Usuwanie deployments..."
kubectl delete deployment service-a service-b postgres

# Usuwanie Services 
echo "Usuwanie services..."
kubectl delete service service-a service-b postgres

# Usuwanie PersistentVolumeClaim
echo "Usuwanie PersistentVolumeClaim..."
kubectl delete pvc postgres-pvc

# Usuwanie PersistentVolume
echo "Usuwanie PersistentVolume..."
kubectl delete pv postgres-pv