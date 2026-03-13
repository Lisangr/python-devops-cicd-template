.PHONY: help install lint test run server-info docker-build docker-run compose-up compose-down compose-logs ansible-check ansible-dry ansible-run docker-test docker-lint docker-clean

help: ## Показать все команды
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Установить зависимости Python
	pip install -r app/requirements.txt

lint: ## Проверить качество кода (flake8 для Python, shellcheck для Bash)
	flake8 app/main.py app/tests/
	shellcheck scripts/*.sh

test: ## Запустить тесты
	pytest app/tests/ -v

run: ## Запустить приложение локально
	cd app && python main.py

server-info: ## Запустить Bash-скрипт диагностики сервера
	./scripts/server-info.sh http://localhost:5000/health

docker-build: ## Собрать Docker образ
	docker build -t simple-app:latest .

docker-run: ## Запустить Docker контейнер
	docker run -d -p 5000:5000 --name simple-app simple-app:latest

compose-up: ## Запустить Docker Compose
	docker-compose up -d

compose-down: ## Остановить Docker Compose
	docker-compose down

compose-logs: ## Просмотреть логи Docker Compose
	docker-compose logs -f app

ansible-check: ## Проверить Ansible playbook синтаксис
	ansible-playbook --syntax-check -i ansible/inventory.ini ansible/playbook.yml

ansible-dry: ## Dry-run Ansible (тестовый запуск)
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check

ansible-run: ## Запустить Ansible playbook
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvv

docker-test: ## Запустить тесты в Docker
	docker build -f Dockerfile.test -t simple-app-test .
	docker run --rm simple-app-test

docker-lint: ## Запустить linting в Docker
	docker run --rm -v "$(PWD)":/app -w /app python:3.12-alpine sh -c "pip install flake8 shellcheck && flake8 app/main.py app/tests/ && shellcheck scripts/*.sh"

docker-clean: ## Очистить Docker образы и контейнеры
	docker system prune -f
	docker rmi simple-app:latest simple-app-test 2>/dev/null || true