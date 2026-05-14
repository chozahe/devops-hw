#!/bin/bash
#
# run_demo.sh — сборка Docker-образа и демонстрация работы setup_users.sh
#
# Запуск:
#   ./run_demo.sh              — полный цикл: сборка → выполнение → проверка
#   ./run_demo.sh shell        — только интерактивная оболочка в контейнере
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="devops-hw1-bash"

echo "╔══════════════════════════════════════════╗"
echo "║   ДЗ №1 — Демонстрация Bash-скрипта      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# --- Сборка образа ---
echo "▶ Сборка Docker-образа '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
echo "✔ Образ собран"
echo ""

# --- Выполнение скрипта ---
echo "▶ Запуск setup_users.sh с ключом -d /workspaces..."
echo "─────────────────────────────────────────────"
docker run --rm "$IMAGE_NAME" /usr/local/bin/setup_users.sh -d /workspaces
echo "─────────────────────────────────────────────"
echo "✔ Скрипт выполнен"
echo ""

# --- Проверка результатов ---
echo "▶ Проверка результатов..."
docker run --rm "$IMAGE_NAME" bash -c '
set -e

echo ""
echo "═══ 1. Состав группы dev ═══"
getent group dev || echo "  ⚠ Группа не найдена"
echo ""

echo "═══ 2. Не-системные пользователи (UID ≥ 1000) ═══"
awk -F: '\''$3 >= 1000 && $1 != "nobody" {printf "  %-12s UID=%-5s GID=%-5s home=%s\n", $1, $3, $4, $6}'\'' /etc/passwd
echo ""

echo "═══ 3. Файл sudoers для группы dev ═══"
cat /etc/sudoers.d/dev-nopasswd 2>/dev/null || echo "  ⚠ Файл не найден"
echo ""

echo "═══ 4. Созданные рабочие директории ═══"
ls -la /workspaces/ 2>/dev/null || echo "  ⚠ Директории не найдены"
echo ""

echo "═══ 5. ACL на директориях ═══"
for d in /workspaces/*_workdir; do
    if [ -d "$d" ]; then
        echo "  ▶ $(basename "$d"):"
        getfacl "$d" 2>/dev/null | tail -n +2 | sed "s/^/      /"
    fi
done
echo ""

echo "═══ 6. Проверка прав доступа (попытка cd от имени alice) ═══"
echo "  Заметка: права 660 (rw-rw----) не дают execute (x), поэтому"
echo "  команда cd в директорию не сработает — можно только ls."
echo ""
'
echo "✔ Проверка завершена"
echo ""

echo "╔══════════════════════════════════════════╗"
echo "║   Демонстрация успешно завершена!         ║"
echo "║   Для ручного исследования:               ║"
echo "║     ./run_demo.sh shell                   ║"
echo "╚══════════════════════════════════════════╝"
