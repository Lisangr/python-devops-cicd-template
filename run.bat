@echo off
echo Simple App Runner for Windows
echo.

if "%1"=="install" goto install
if "%1"=="test" goto test
if "%1"=="lint" goto lint
if "%1"=="run" goto run
if "%1"=="help" goto help

:help
echo Available commands:
echo   install  - Install Python dependencies
echo   test     - Run tests
echo   lint     - Run linting
echo   run      - Run application
echo.
echo Usage: run.bat [command]
goto end

:install
echo Installing dependencies...
pip install -r app/requirements.txt
goto end

:test
echo Running tests...
pytest app/tests/ -v
goto end

:lint
echo Running linting...
flake8 app/main.py app/tests/
shellcheck scripts/*.sh
goto end

:run
echo Starting application...
cd app
python main.py
goto end

:end
echo Done.
