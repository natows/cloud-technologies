#!/bin/bash

docker login
docker build -t python-app .
docker tag python-app nowsiejko/python-app:1.0
docker push nowsiejko/python-app:1.0



kubectl apply -f pod.yaml

kubectl wait --for=condition=ready pod/hello-pod --timeout=60s

kubectl get pods


kubectl port-forward pod/hello-pod 5000:5000 &
PORT_FORWARD_PID=$!

sleep 5

echo "Testowanie aplikacji za pomocą curl"
curl http://localhost:5000
echo ""
kill $PORT_FORWARD_PID

echo "Aktualizacja aplikacji"

cat <<EOF > app.py
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"

@app.route('/new')
def new():
    return "Nowy endpoint"

if __name__=="__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
EOF
docker build -t python-app .
docker tag python-app nowsiejko/python-app:1.1
docker push nowsiejko/python-app:1.1
kubectl delete pod hello-pod
sed -i 's/nowsiejko\/python-app:1.0/nowsiejko\/python-app:1.1/' pod.yaml
kubectl apply -f pod.yaml
kubectl wait --for=condition=ready pod/hello-pod --timeout=60s
kubectl port-forward pod/hello-pod 5000:5000 &
PORT_FORWARD_PID=$!
sleep 5
echo "Testowanie aplikacji za pomocą curl"
curl http://localhost:5000/new
echo ""
kill $PORT_FORWARD_PID
kubectl delete pod hello-pod

