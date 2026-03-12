# DevOps Test App

Простое REST API приложение с полным DevOps стеком для демонстрации навыков.

## 📋 Содержание

- [Приложение](#-приложение)
- [Структура проекта](#-структура-проекта)
- [Быстрый старт](#-быстрый-старт)
- [Разработка](#-разработка)
- [Тестирование](#-тестирование)
- [Развертывание](#-развертывание)
- [CI/CD](#cicd)

## 🚀 Приложение

Flask REST API с endpoints:
- `GET /` - Hello World
- `GET /health` - Health check
- `GET /api/users` - Получить пользователей
- `POST /api/users` - Создать пользователя
- `GET /api/users/<id>` - Получить пользователя по ID
- `DELETE /api/users/<id>` - Удалить пользователя

## 📁 Структура проекта

```
simple-app/
├── app/
│   ├── main.py              # REST API приложение
│   ├── requirements.txt      # зависимости Python
│   └── tests/
│       └── test_app.py       # тесты
├── scripts/
│   └── server-info.sh        # Bash-скрипт диагностики
├── Dockerfile               # контейнеризация
├── docker-compose.yml       # локальное развертывание
├── ansible/
│   ├── playbook.yml         # Ansible playbook
│   ├── inventory.ini         # список серверов
│   └── roles/
│       ├── docker/
│       │   └── tasks/main.yml
│       └── app/
│           └── tasks/main.yml
├── .github/
│   └── workflows/
│       └── build.yml        # GitHub Actions
├── README.md                # документация
└── Makefile                 # команды
```

## ⚡ Быстрый старт

### Через Make (рекомендуется)
```bash
# Установка зависимостей
make install

# Запуск тестов
make test

# Сборка и запуск через Docker Compose
make compose-up

# Остановка
make compose-down
```

### Вручную
```bash
# Python окружение
pip install -r app/requirements.txt

# Запуск приложения
cd app && python main.py

# Или через Docker
docker build -t simple-app:latest .
docker run -p 5000:5000 simple-app:latest
```

## 🧪 Тестирование

```bash
# Запуск всех тестов
pytest app/tests/ -v

# Запуск конкретного теста
pytest app/tests/test_app.py::test_health -v

# С покрытием кода
pytest app/tests/ --cov=app --cov-report=html
```

## 🔧 Разработка

### Локальная разработка
```bash
# Запуск в режиме разработки
FLASK_ENV=development python app/main.py

# Проверка кода
make lint

# Диагностика сервера
./scripts/server-info.sh http://localhost:5000/health
```

### Docker разработка
```bash
# Сборка образа
make docker-build

# Запуск с volume для разработки
docker-compose up -d

# Просмотр логов
docker-compose logs -f app
```

## 🚀 Развертывание

### Docker Compose
```bash
# Продакшн развертывание
docker-compose -f docker-compose.yml up -d

# Проверка здоровья
curl http://localhost:5000/health
```

### Ansible
```bash
# Проверка синтаксиса
ansible-playbook --syntax-check -i ansible/inventory.ini ansible/playbook.yml

# Dry run
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check

# Развертывание
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvv
```

## 🔄 CI/CD

GitHub Actions автоматически:
- Линтит Bash скрипты (shellcheck)
- Запускает тесты (pytest)
- Собирает Docker образ
- Проверяет health endpoint
- Работает на push и PR в main ветку

## 📊 Мониторинг

### Health Checks
```bash
# Приложение
curl http://localhost:5000/health

# Docker контейнеры
docker ps
docker-compose ps
```

### Логи
```bash
# Docker Compose логи
docker-compose logs -f app

# Ansible развертывание
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvv
```

## 🛠️ Доступные команды (Make)

```bash
help          # Показать справку
install       # Установка зависимостей
test          # Запуск тестов
lint          # Проверка кода
docker-build  # Сборка образа
compose-up    # Запуск Docker Compose
compose-down  # Остановка Docker Compose
ansible-check # Проверка Ansible
```

## 📝 API Documentation

### Endpoints

#### GET /
```json
{"message": "Hello, World!"}
```

#### GET /health
```json
{"status": "ok"}
```

#### GET /api/users
```json
{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]}
```

#### POST /api/users
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe"}'
```

#### GET /api/users/<id>
```json
{"id": 1, "name": "Alice"}
```

#### DELETE /api/users/<id>
```json
{"message": "User deleted successfully", "user": {"id": 1, "name": "Alice"}}
```

## 🐛 Troubleshooting

### Общие проблемы
1. **Порт занят**: `sudo lsof -i :5000`
2. **Docker проблемы**: `docker system prune`
3. **Python зависимости**: `pip install --upgrade pip`

### Ansible проблемы
```bash
# Проверка подключения
ansible webservers -i ansible/inventory.ini -m ping

# Проверка зависимостей
ansible-galaxy collection install -r ansible/requirements.yml
```

## 📄 Лицензия

MIT License - свободное использование и модификация.