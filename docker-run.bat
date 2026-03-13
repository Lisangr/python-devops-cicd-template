@echo off
echo Docker Test Runner for Windows
echo.

if "%1"=="test" goto test
if "%1"=="lint" goto lint
if "%1"=="build" goto build
if "%1"=="run" goto run
if "%1"=="clean" goto clean
if "%1"=="help" goto help

:help
echo Available commands:
echo   test     - Run tests in Docker
echo   lint     - Run linting in Docker  
echo   build    - Build Docker image
echo   run      - Run Docker container
echo   clean    - Clean Docker images
echo.
echo Usage: docker-run.bat [command]
goto end

:test
echo Running tests in Docker...
echo Building test image...
docker build -f Dockerfile.test -t simple-app-test .
if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    goto end
)
echo Running tests...
docker run --rm simple-app-test
goto end

:lint
echo Running linting in Docker...
docker run --rm -v "%CD%":/app -w /app python:3.12-alpine sh -c "apk add --no-cache shellcheck && pip install flake8 && flake8 app/main.py app/tests/ && shellcheck scripts/*.sh"
goto end

:build
echo Building Docker image...
docker build -t simple-app:latest .
goto end

:run
echo Running Docker container...
docker stop simple-app 2>nul
docker rm simple-app 2>nul
docker run -d -p 5000:5000 --name simple-app simple-app:latest
echo Container started. Access: http://localhost:5000
goto end

:clean
echo Cleaning Docker...
docker system prune -f
docker rmi simple-app:latest simple-app-test 2>nul
goto end

:end
echo Done.
