# DevOps Test Project

Полный стек DevOps для демонстрации навыков автоматизации и развертывания.

## 🎯 Задания выполнены

### ✅ Обязательная часть
- [x] **REST API на Python** - Flask приложение с полным CRUD
- [x] **Bash-скрипт диагностики** - системная информация и health checks
- [x] **Docker контейнеризация** - multi-stage build с security best practices
- [x] **Docker Compose** - локальное развертывание с health checks
- [x] **Тестирование** - pytest с покрытием всех endpoints
- [x] **Документация** - подробное README с примерами

### ✅ Продвинутая часть
- [x] **GitHub Actions CI** - автоматический pipeline с тестами
- [x] **Ansible** - автоматизация развертывания на серверах
- [x] **Makefile** - удобные команды для работы с проектом
- [x] **Логирование** - структурированное логирование в приложении
- [x] **Handlers в Ansible** - обработчики для перезапуска сервисов

## 🚀 Технологии

- **Backend**: Python 3.12, Flask, Gunicorn
- **Testing**: Pytest
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Infrastructure as Code**: Ansible
- **Shell Scripting**: Bash с shellcheck
- **Code Quality**: Flake8, Shellcheck

## 📊 Статус проекта

- ✅ Все тесты проходят (9/9)
- ✅ Docker образ собирается и работает
- ✅ CI/CD pipeline настроен
- ✅ Ansible playbook готов к развертыванию
- ✅ Документация полная и актуальная

## 🔄 CI/CD Pipeline

Автоматически выполняется при:
- Push в main ветку
- Pull Request в main ветку

Этапы:
1. Checkout кода
2. Setup Python 3.12
3. Установка зависимостей
4. Линтинг Bash скриптов (shellcheck)
5. Запуск тестов (pytest)
6. Сборка Docker образа
7. Запуск контейнера и проверка health

## 📈 Результаты

Проект демонстрирует полный цикл разработки и развертывания:
- Кодирование и тестирование
- Контейнеризация
- Автоматизация CI/CD
- Infrastructure as Code
- Мониторинг и логирование

Готов к выкатке в production! 🚀
