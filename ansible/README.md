# Ansible Deployment Guide

## Overview
This Ansible playbook automates the deployment of the Simple App application on Ubuntu servers.

## Prerequisites
- Ubuntu 20.04+ target servers
- Ansible control node with Python 3.8+
- SSH access to target servers with sudo privileges

## Installation
```bash
# Install Ansible collections
ansible-galaxy collection install -r ansible/requirements.yml

# Install required Python packages
pip install ansible docker-compose
```

## Usage

### 1. Check syntax
```bash
ansible-playbook --syntax-check -i ansible/inventory.ini ansible/playbook.yml
```

### 2. Dry run (check mode)
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check
```

### 3. Deploy application
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

### 4. Deploy with verbose logging
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -vvv
```

### 5. Deploy specific tasks
```bash
# Only install Docker
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags docker

# Only deploy app
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags app
```

## Structure
```
ansible/
├── playbook.yml          # Main playbook
├── inventory.ini          # Target servers
├── requirements.yml       # Ansible collections
└── roles/
    ├── docker/
    │   ├── tasks/main.yml    # Docker installation tasks
    │   └── handlers/main.yml # Docker handlers
    └── app/
        ├── tasks/main.yml    # App deployment tasks
        └── handlers/main.yml # App handlers
```

## What the playbook does

### Docker Role
- Updates apt cache
- Installs required packages (curl, apt-transport-https, etc.)
- Adds Docker GPG key and repository
- Installs Docker CE and docker-compose
- Starts and enables Docker service
- Adds current user to docker group

### App Role
- Creates `/opt/simple-app` directory
- Copies application files to server
- Builds Docker image
- Starts application with docker-compose
- Waits for container to be ready
- Checks health endpoint
- Verifies container status

## Variables
- `app_dir`: Application directory (default: `/opt/simple-app`)
- `ansible_user`: SSH user for deployment

## Post-deployment
After deployment, the application will be available at:
- Health check: http://<server-ip>:5000/health
- API endpoints: http://<server-ip>:5000/api/

## Troubleshooting
1. Check Docker service: `systemctl status docker`
2. Check container logs: `docker logs simple-app`
3. Check application logs: `docker-compose logs -f`
4. Verify port: `netstat -tlnp | grep 5000`
