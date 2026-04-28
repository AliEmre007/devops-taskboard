# DevOps TaskBoard

DevOps TaskBoard is a professional step-by-step DevOps learning project.

The purpose of this project is to learn real DevOps practices by building a production-style application environment from scratch.

## Current Stage

Initial project structure and basic automation scripts are completed.

## Learning Goals

This project will gradually cover:

- Linux fundamentals
- Shell scripting
- Git and Git workflow
- Docker
- Docker Compose
- CI/CD with GitHub Actions
- Nginx reverse proxy
- PostgreSQL
- Redis
- Infrastructure as Code with Terraform
- Configuration management with Ansible
- Kubernetes basics
- Monitoring with Prometheus and Grafana
- Backup and rollback procedures
- Troubleshooting and runbooks

## Project Structure

```text
devops-taskboard/
├── app/
│   ├── src/
│   ├── tests/
│   ├── package.json
│   └── Dockerfile
├── nginx/
│   └── nginx.conf
├── scripts/
│   ├── bootstrap.sh
│   ├── test.sh
│   ├── build.sh
│   ├── deploy.sh
│   ├── rollback.sh
│   ├── healthcheck.sh
│   ├── backup-db.sh
│   └── logs.sh
├── infra/
│   ├── terraform/
│   └── ansible/
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── monitoring/
│   ├── prometheus.yml
│   └── grafana/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
├── docker-compose.yml
├── docker-compose.prod.yml
├── Makefile
├── .env.example
├── README.md
└── runbook.md

## Docker Build

Build the API Docker image:

```bash
make build

## Docker Compose with PostgreSQL and Redis

Start the full local stack:

```bash
docker compose up -d --build

## Nginx Reverse Proxy

The application is accessed through Nginx.

```text
localhost:8080 -> Nginx -> app:3000
