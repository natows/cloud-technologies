#!/bin/bash

PASSWORD="haslo"
echo "tworzenie kontenera z wolumenem"
docker volume create my_secure_volume
docker run -d --name my_secure_container -v my_secure_volume:/data busybox sleep infinity

mkdir -p backup
docker cp my_secure_container:/data/. backup

echo "tworzenie archiwum i szyfrowanie"
tar -cf - backup | gpg --batch --yes --passphrase "$PASSWORD" -c -o "zaszyfrowany.tar.gpg"
echo "zaszyfrowano jako zaszyfrowany.tar.gpg"

echo "odszyfrowywanie danych"
gpg --batch --yes --passphrase "$PASSWORD" -d "zaszyfrowany.tar.gpg" | tar -x
echo "dane odszyfrowane"

echo "usuwanie kontenera i wolumenu"
docker rm -f my_secure_container
docker volume rm my_secure_volume
rm -rf backup zaszyfrowany.tar.gpg


