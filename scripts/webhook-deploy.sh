#!/bin/bash

# Webhook deploy script
# Запускается на сервере при получении webhook от GitHub

echo "Starting webhook deploy at $(date)"

# Переходим в директорию проекта
cd /opt/simple-app || exit 1

# Получаем последние изменения
git pull origin main

# Запускаем Ansible для развертывания
make ansible-run

echo "Deploy completed at $(date)"
