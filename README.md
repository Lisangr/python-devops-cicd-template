# DevOps Test App

Простое REST API приложение с полным DevOps стеком для демонстрации навыков автоматизации и развертывания.

## 📋 Описание

DevOps Test App - это комплексный проект, демонстрирующий навыки разработки, тестирования, контейнеризации и автоматизации развертывания. Проект включает Flask REST API, Bash скрипты диагностики, Docker контейнеризацию, CI/CD pipeline и Ansible автоматизацию.

## 🔧 Требования

- **Python 3.12+** - для запуска приложения и тестов
- **Docker** - для контейнеризации
- **Docker Compose** - для локального развертывания
- **Ansible** - для автоматизации развертывания на серверах
- **Git** - для контроля версий

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

### Локальный запуск приложения

```bash
# Установка зависимостей
pip install -r app/requirements.txt

# Запуск приложения
python app/main.py

# Проверка работы
curl http://localhost:5000/health
```

### Запуск через Docker Compose

```bash
# Сборка и запуск
docker-compose up -d

# Проверка здоровья
curl http://localhost:5000/health

# Просмотр логов
docker-compose logs -f app

# Остановка
docker-compose down
```

## 📝 API Endpoints

### Описание с примерами curl

#### GET / - Приветствие
```bash
curl http://localhost:5000/
```
**Ответ:**
```json
{"message": "Hello, World!"}
```

#### GET /health - Проверка здоровья
```bash
curl http://localhost:5000/health
```
**Ответ:**
```json
{"status": "ok"}
```

#### GET /api/users - Получить всех пользователей
```bash
curl http://localhost:5000/api/users
```
**Ответ:**
```json
{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]}
```

#### POST /api/users - Создать пользователя
```bash
curl -X POST http://localhost:5000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe"}'
```
**Ответ:**
```json
{"id": 3, "name": "John Doe"}
```

#### GET /api/users/<id> - Получить пользователя по ID
```bash
curl http://localhost:5000/api/users/1
```
**Ответ:**
```json
{"id": 1, "name": "Alice"}
```

#### DELETE /api/users/<id> - Удалить пользователя
```bash
curl -X DELETE http://localhost:5000/api/users/1
```
**Ответ:**
```json
{"message": "User deleted successfully", "user": {"id": 1, "name": "Alice"}}
```

## 🔍 Bash-скрипт диагностики

### Описание
`scripts/server-info.sh` - комплексный скрипт для диагностики сервера и проверки доступности сервисов.

### Примеры использования

```bash
# Помощь
./scripts/server-info.sh --help

# Полная диагностика с проверкой сервисов
./scripts/server-info.sh http://localhost:5000/health http://localhost:8080/health

# Только системная информация
./scripts/server-info.sh

# С настройкой таймаута
./scripts/server-info.sh --timeout 5 http://localhost:5000/health
```

### Функциональность
- Системная информация (hostname, OS, kernel, uptime)
- Использование ресурсов (CPU, RAM, disk)
- Статус Docker контейнеров
- Health checks для HTTP сервисов
- Цветной вывод и логирование

## 🧪 Тестирование

### Как запустить тесты

```bash
# Запуск всех тестов
pytest app/tests/ -v

# Запуск конкретного теста
pytest app/tests/test_app.py::test_health -v

# Запуск с покрытием кода
pytest app/tests/ --cov=app --cov-report=html

# Запуск через Make
make test
```

### Доступные тесты
- `test_index` - проверка GET /
- `test_health` - проверка GET /health
- `test_get_users` - проверка GET /api/users
- `test_create_user_success` - успешное создание пользователя
- `test_create_user_fail` - ошибка валидации
- `test_get_user_success` - получение пользователя
- `test_get_user_not_found` - пользователь не найден
- `test_delete_user_success` - успешное удаление
- `test_delete_user_not_found` - удаление несуществующего

## 🚀 Ansible развертывание

### Шаги по развертыванию

#### 1. Установка зависимостей Ansible
```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

#### 2. Настройка инвентаря
Отредактируйте `ansible/inventory.ini`:
```ini
[webservers]
app-server-1 ansible_host=10.0.1.10 ansible_user=root
```

#### 3. Проверка синтаксиса
```bash
ansible-playbook --syntax-check -i ansible/inventory.ini ansible/playbook.yml
```

#### 4. Dry run (тестовый запуск)
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check
```

#### 5. Развертывание
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvv
```

#### 6. Проверка подключения
```bash
ansible webservers -i ansible/inventory.ini -m ping
```

### Что делает Ansible
- Устанавливает Docker и docker-compose
- Создает директорию приложения
- Копирует файлы приложения
- Собирает Docker образ
- Запускает приложение через docker-compose
- Проверяет health endpoint

## 🛠️ Make команды

```bash
make help          # Показать справку
make install       # Установка зависимостей
make test          # Запуск тестов
make lint          # Проверка кода
make docker-build  # Сборка образа
make compose-up    # Запуск Docker Compose
make compose-down  # Остановка Docker Compose
make ansible-check # Проверка Ansible
```

## � CI/CD

GitHub Actions автоматически выполняет:
- Линтинг Bash скриптов (shellcheck)
- Запуск тестов (pytest)
- Сборку Docker образа
- Проверку health endpoint
- Работает на push и PR в main ветку

## 🐛 Troubleshooting

### Решение проблем

#### Порт занят
```bash
# Найти процесс
sudo lsof -i :5000

# Убить процесс
sudo kill -9 <PID>
```

#### Docker проблемы
```bash
# Очистка Docker
docker system prune -a

# Пересборка образа
docker build --no-cache -t simple-app:latest .
```

#### Python зависимости
```bash
# Обновление pip
pip install --upgrade pip

# Переустановка зависимостей
pip install -r app/requirements.txt --force-reinstall
```

#### Ansible проблемы
```bash
# Проверка подключения
ansible webservers -i ansible/inventory.ini -m ping

# Установка коллекций
ansible-galaxy collection install -r ansible/requirements.yml

# Подробное логирование
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvvv
```

#### Проблемы с Bash скриптом
```bash
# Проверка синтаксиса
shellcheck scripts/server-info.sh

# Запуск с отладкой
bash -x scripts/server-info.sh --help
```

## 📄 Лицензия

MIT License - свободное использование и модификация.