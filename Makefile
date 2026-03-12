help: ## Справка
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Установка зависимостей
	pip install -r app/requirements.txt

test: ## Запуск тестов
	pytest app/tests/ -v

lint: ## Проверка кода
	flake8 app/main.py

docker-build: ## Сборка образа
	docker build -t simple-app:latest .

compose-up: ## Запуск Docker Compose
	docker-compose up -d

ansible-check: ## Проверка Ansible
	ansible-playbook --syntax-check -i ansible/inventory.ini ansible/playbook.yml