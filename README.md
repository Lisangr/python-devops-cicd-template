# Python REST API & Full DevOps CI/CD Template

Эталонный продакшн-шаблон микросервиса на базе Flask REST API с полным циклом автоматизации жизненного цикла: юнит-тестирование (`pytest`), статический анализ кода и скриптов (`flake8`, `shellcheck`), контейнеризация (Docker Compose v2), конфигурационный менеджмент (модульные роли Ansible) и CI/CD пайплайн на GitHub Actions.

## 📋 Описание

Проект представляет собой готовый каркас для быстрого развертывания и сопровождения Python-сервисов на Linux-серверах. Включает REST API с покрытием тестами, автономный Bash-скрипт диагностики хоста и healthcheck-проверок, стандартизированный `Makefile`, идемпотентные роли Ansible и автоматический пайплайн сборки, тестирования и доставки.

## 🔧 Требования

- **Python 3.12+** — для запуска приложения и тестов
- **Docker Engine** — для контейнеризации
- **Docker Compose v2** (`docker compose`) — для локального и серверного развертывания
- **Ansible 2.15+** — для автоматизации настройки серверов и деплоя
- **Git** — для контроля версий

## 📁 Структура проекта

```text
python-devops-cicd-template/
├── app/
│   ├── main.py              # Flask REST API приложение
│   ├── requirements.txt     # Зависимости Python
│   └── tests/
│       └── test_app.py      # Юнит-тесты (pytest)
├── scripts/
│   └── server-info.sh       # Bash-скрипт системной диагностики и healthcheck
├── ansible/
│   ├── playbook.yml         # Основной Ansible playbook
│   ├── inventory.ini        # Инвентарь целевых серверов
│   └── roles/
│       ├── docker/
│       │   └── tasks/main.yml
│       └── app/
│           └── tasks/main.yml
├── .github/
│   └── workflows/
│       └── ci-cd.yml        # GitHub Actions (CI тесты + CD деплой)
├── Dockerfile               # Многоэтапная/оптимизированная сборка образа
├── docker-compose.yml       # Оркестрация контейнеров
├── Makefile                 # Шорткаты для разработки, тестов и деплоя
├── .flake8                  # Конфигурация линтера Python
└── README.md                # Документация проекта
```

## ⚡ Быстрый старт

### 1. Клонирование репозитория

```bash
git clone https://github.com
cd python-devops-cicd-template
```

### 2. Запуск через Docker Compose

```bash
# Сборка и запуск в фоновом режиме
docker compose up -d --build

# Проверка здоровья сервиса
curl -f http://localhost:5000/health

# Просмотр логов приложения
docker compose logs -f app

# Остановка и удаление контейнеров
docker compose down
```

### 3. Локальный запуск (для разработки)

```bash
pip install -r app/requirements.txt
python app/main.py
curl -f http://localhost:5000/health
```

## 📝 API Endpoints

#### `GET /` — Приветствие
```bash
curl http://localhost:5000/
```
**Ответ:**
```json
{"message": "Hello, World!"}
```

#### `GET /health` — Проверка здоровья (Healthcheck)
```bash
curl http://localhost:5000/health
```
**Ответ:**
```json
{"status": "ok"}
```

#### `GET /api/users` — Получить список пользователей
```bash
curl http://localhost:5000/api/users
```
**Ответ:**
```json
{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]}
```

#### `POST /api/users` — Создать пользователя
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe"}'
```
**Ответ:**
```json
{"id": 3, "name": "John Doe"}
```

#### `GET /api/users/<id>` — Получить пользователя по ID
```bash
curl http://localhost:5000/api/users/1
```
**Ответ:**
```json
{"id": 1, "name": "Alice"}
```

#### `DELETE /api/users/<id>` — Удалить пользователя
```bash
curl -X DELETE http://localhost:5000/api/users/1
```
**Ответ:**
```json
{"message": "User deleted successfully", "user": {"id": 1, "name": "Alice"}}
```

## 🔍 Bash-скрипт диагностики

`scripts/server-info.sh` — автономная утилита для быстрого аудита состояния сервера и проверки доступности HTTP-эндпоинтов.

```bash
# Справка по флагам
./scripts/server-info.sh --help

# Полная диагностика с проверкой сервисов
./scripts/server-info.sh http://localhost:5000/health http://localhost:8080/health

# Только системные метрики хоста
./scripts/server-info.sh

# Проверка с кастомным таймаутом
./scripts/server-info.sh --timeout 5 http://localhost:5000/health
```

**Собираемые данные:**
- Системная информация (`hostname`, OS, версия ядра, `uptime`)
- Утилизация ресурсов (CPU Load Average, RAM, дисковое пространство)
- Статус запущенных Docker-контейнеров
- HTTP Healthcheck целевых сервисов с логированием

## 🧪 Тестирование и линтинг

```bash
# Запуск всех тестов с подробным выводом
pytest app/tests/ -v

# Запуск конкретного теста
pytest app/tests/test_app.py::test_health -v

# Запуск с генерацией отчета покрытия (Coverage)
pytest app/tests/ --cov=app --cov-report=html

# Запуск через Makefile
make test
make lint
```

**Покрытие тестами:** `test_index`, `test_health`, `test_get_users`, `test_create_user_success`, `test_create_user_fail`, `test_get_user_success`, `test_get_user_not_found`, `test_delete_user_success`, `test_delete_user_not_found`.

## 🚀 Ansible развертывание

### 1. Подготовка и проверка

```bash
# Установка необходимых коллекций Ansible
ansible-galaxy collection install -r ansible/requirements.yml

# Настройка целевого хоста в ansible/inventory.ini
# [webservers]
# app-server-1 ansible_host=10.0.1.10 ansible_user=deploy

# Проверка синтаксиса плейбука
ansible-playbook --syntax-check -i ansible/inventory.ini ansible/playbook.yml

# Проверка SSH-доступности хостов
ansible webservers -i ansible/inventory.ini -m ping
```

### 2. Dry-run и боевой прогон

```bash
# Тестовый прогон без внесения изменений (--check)
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check

# Боевое развертывание
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -v
```

**Этапы работы ролей Ansible:**
- Установка Docker Engine и плагина Docker Compose (`role: docker`)
- Подготовка директории приложения и синхронизация файлов (`role: app`)
- Сборка образа, запуск контейнеров и проверка `/health` эндпоинта

## 🛠️ Make команды

```bash
make help          # Показать список доступных команд
make install       # Установка Python-зависимостей
make test          # Запуск юнит-тестов (pytest)
make lint          # Проверка стиля кода (flake8)
make docker-build  # Сборка Docker-образа
make compose-up    # Запуск стека через Docker Compose
make compose-down  # Остановка стека
make ansible-check # Проверка синтаксиса Ansible
```

## 🔄 CI/CD (GitHub Actions)

Пайплайн в `.github/workflows/ci-cd.yml` срабатывает автоматически при `push` и `pull_request` в ветку `main`:
1. **Linting:** проверка Bash-скриптов через `shellcheck` и кода Python через `flake8`.
2. **Unit Tests:** прогон тестового набора `pytest`.
3. **Container Smoke Test:** сборка Docker-образа, запуск контейнера и проверка ответа `/health`.
4. **Continuous Deployment:** автоматический запуск `ansible-playbook` по SSH при успешном прохождении CI в ветке `main` (при наличии секретов `SERVER_HOST`, `SERVER_USER`, `SSH_PRIVATE_KEY`).

## 🐛 Troubleshooting

#### Порт 5000 уже занят
```bash
sudo ss -tulpn | grep :5000
# Завершить мешающий процесс или переопределить порт в docker-compose.yml
```

#### Ошибки сборки или кэша Docker
```bash
docker compose down --rmi local
docker build --no-cache -t simple-app:latest .
```

#### Отладка Bash-скриптов и Ansible
```bash
# Проверка синтаксиса и трассировка выполнения скрипта
shellcheck scripts/server-info.sh
bash -x scripts/server-info.sh --help

# Запуск Ansible с максимальной детализацией вывода
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvvv
```

## 📄 Лицензия

MIT License — свободное использование и модификация.
