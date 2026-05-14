#!/bin/bash
#
# run_demo.sh — сборка Docker-окружения и запуск Ansible playbook (ДЗ №2)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔══════════════════════════════════════════╗"
echo "║   ДЗ №2 — Демонстрация Ansible Playbook   ║"
echo "╚══════════════════════════════════════════╝"
echo ""

echo "▶ Сборка Docker-образов..."
docker compose build --no-cache
echo "✔ Образы собраны"
echo ""

echo "▶ Запуск окружения и выполнение playbook..."
docker compose up --abort-on-container-exit --exit-code-from control
echo ""
echo "✔ Демонстрация завершена"
echo ""

echo "▶ Остановка и удаление контейнеров..."
docker compose down -v 2>/dev/null || true
echo "✔ Очищено"
