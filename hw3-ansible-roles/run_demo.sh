#!/bin/bash
#
# run_demo.sh — запуск Molecule-тестов для ролей (ДЗ №3)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔══════════════════════════════════════════╗"
echo "║  ДЗ №3 — Molecule-тесты Ansible ролей    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if ! command -v molecule &>/dev/null; then
    echo "⚠ molecule не установлен. Устанавливаю..."
    pip install molecule molecule-docker ansible-lint
    echo ""
fi

cd molecule/default

if [ "${1:-test}" = "test" ]; then
    echo "▶ Запуск полного цикла: molecule test"
    molecule test
elif [ "$1" = "converge" ]; then
    echo "▶ Создание и настройка: molecule converge"
    molecule converge
elif [ "$1" = "verify" ]; then
    echo "▶ Проверка: molecule verify"
    molecule verify
elif [ "$1" = "destroy" ]; then
    echo "▶ Удаление: molecule destroy"
    molecule destroy
else
    echo "Неизвестная команда: $1"
    echo "Используйте: test, converge, verify, destroy"
    exit 1
fi

echo ""
echo "✔ Готово"
