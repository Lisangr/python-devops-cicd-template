# Docker Commands for Windows

## 🪟 Windows Batch Scripts

Поскольку `make` недоступен в Windows, созданы альтернативные скрипты:

### 🚀 docker-run.bat - Docker операции
```bash
# Тесты в Docker
docker-run.bat test

# Линтинг в Docker
docker-run.bat lint

# Сборка образа
docker-run.bat build

# Запуск контейнера
docker-run.bat run

# Очистка Docker
docker-run.bat clean

# Справка
docker-run.bat help
```

### 💻 run.bat - Локальные операции
```bash
# Установка зависимостей
run.bat install

# Запуск тестов
run.bat test

# Линтинг
run.bat lint

# Запуск приложения
run.bat run

# Справка
run.bat help
```

## 🐳 Прямые Docker команды

### Тестирование
```bash
# Сборка тестового образа
docker build -f Dockerfile.test -t simple-app-test .

# Запуск тестов
docker run --rm simple-app-test
```

### Линтинг
```bash
docker run --rm -v "%CD%":/app -w /app python:3.12-alpine sh -c "pip install flake8 shellcheck && flake8 app/main.py app/tests/ && shellcheck scripts/*.sh"
```

### Приложение
```bash
# Сборка
docker build -t simple-app:latest .

# Запуск
docker run -d -p 5000:5000 --name simple-app simple-app:latest

# Проверка
curl http://localhost:5000/health
```

### Docker Compose
```bash
# Запуск
docker-compose up -d

# Логи
docker-compose logs -f app

# Остановка
docker-compose down
```

## 🔧 Установка make в Windows (опционально)

### Через Chocolatey
```bash
choco install make
```

### Через Scoop
```bash
scoop install make
```

### Через WSL
```bash
wsl --install
sudo apt update && sudo apt install make
```

## 📋 Рекомендуемый workflow в Windows

1. **Разработка**: `run.bat install`, `run.bat test`
2. **Docker тестирование**: `docker-run.bat test`
3. **Продакшн**: `docker-compose up -d`
4. **Очистка**: `docker-run.bat clean`

Теперь у вас есть полная поддержка Windows! 🎉
