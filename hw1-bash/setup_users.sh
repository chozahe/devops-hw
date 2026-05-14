#!/bin/bash
#
# setup_users.sh — Bash-скрипт для домашнего задания №1 по DevOps
#
# Функции:
#   1. Создаёт группу dev
#   2. Добавляет всех не-системных пользователей (UID >= 1000) в группу dev
#   3. Выдаёт группе dev права sudo без запроса пароля
#   4. Создаёт директории по маске <user_name>_workdir
#   5. Путь задаётся ключом -d или запрашивается интерактивно
#   6. Права 660, владелец — пользователь, группа — группа пользователя
#   7. ACL на чтение для группы dev на каждую созданную директорию
#   8. Логирование в stdout и файл
#
# Использование:
#   sudo ./setup_users.sh -d /путь/к/директориям
#   sudo ./setup_users.sh              # путь будет запрошен интерактивно
#   sudo ./setup_users.sh -d /tmp -n   # dry-run (без реальных изменений)

set -euo pipefail

# ─── Конфигурация ────────────────────────────────────────────────────────────

LOG_FILE="/var/log/setup_users.log"
WORKDIR_BASE=""
MIN_UID=1000          # минимальный UID «не-системного» пользователя
EXCLUDE_USERS=("nobody")  # пользователи, которых пропускаем

# ─── Функции ─────────────────────────────────────────────────────────────────

log() {
    local msg="$1"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "${timestamp} — ${msg}" | tee -a "$LOG_FILE"
}

usage() {
    cat <<EOF
Использование: $0 [ОПЦИИ]

Обязательный параметр:
  -d <путь>   Базовый путь для создания рабочих директорий (например, /home/workspaces)

Дополнительно:
  -n          Dry-run: показать, что было бы сделано, без реальных изменений
  -h          Показать эту справку

Примеры:
  sudo $0 -d /opt/workspaces
  sudo $0 -d /home/user_dirs -n
EOF
    exit 0
}

is_excluded() {
    local user="$1"
    for ex in "${EXCLUDE_USERS[@]}"; do
        [[ "$user" == "$ex" ]] && return 0
    done
    return 1
}

# ─── Проверка прав ───────────────────────────────────────────────────────────

if [[ "$EUID" -ne 0 ]]; then
    echo "ОШИБКА: скрипт должен выполняться от root (sudo). Завершение."
    exit 1
fi

# ─── Парсинг аргументов ─────────────────────────────────────────────────────

DRY_RUN=false

while getopts "d:nh" opt; do
    case $opt in
        d) WORKDIR_BASE="$OPTARG" ;;
        n) DRY_RUN=true ;;
        h) usage ;;
        *) echo "Неизвестный ключ: -$OPTARG. Используйте -h для справки."; exit 1 ;;
    esac
done

# Если путь не задан — запрашиваем интерактивно
if [[ -z "$WORKDIR_BASE" ]]; then
    read -rp "Введите путь для создания рабочих директорий: " WORKDIR_BASE
fi

if [[ -z "$WORKDIR_BASE" ]]; then
    log "ОШИБКА: путь не указан. Завершение."
    exit 1
fi

# ─── Основная логика ─────────────────────────────────────────────────────────

log "=============================================="
log "ЗАПУСК СКРИПТА НАСТРОЙКИ ПОЛЬЗОВАТЕЛЕЙ"
log "Целевой путь: $WORKDIR_BASE"
log "Режим: $([ "$DRY_RUN" = true ] && echo 'DRY-RUN (без изменений)' || echo 'РЕАЛЬНЫЙ')"
log "=============================================="

# --- Шаг 1: Создание группы dev ---
log "Шаг 1/7: Создание группы dev..."
if [[ "$DRY_RUN" = false ]]; then
    if getent group dev >/dev/null 2>&1; then
        log "  Группа dev уже существует (GID: $(getent group dev | cut -d: -f3))"
    else
        groupadd dev
        log "  Группа dev создана"
    fi
else
    log "  [DRY-RUN] groupadd dev"
fi

# --- Шаг 2: Добавление не-системных пользователей в группу dev ---
log "Шаг 2/7: Добавление не-системных пользователей (UID >= $MIN_UID) в группу dev..."

while IFS=: read -r username _ uid _ _ _ _; do
    if [[ "$uid" -ge "$MIN_UID" ]] && ! is_excluded "$username"; then
        if [[ "$DRY_RUN" = false ]]; then
            if usermod -aG dev "$username" 2>/dev/null; then
                log "  ✓ $username (UID=$uid) добавлен в группу dev"
            else
                log "  ✗ Не удалось добавить $username в группу dev"
            fi
        else
            log "  [DRY-RUN] usermod -aG dev $username"
        fi
    fi
done < /etc/passwd

# --- Шаг 3: Выдача sudo без пароля для группы dev ---
log "Шаг 3/7: Настройка sudo без пароля для группы dev..."
SUDOERS_FILE="/etc/sudoers.d/dev-nopasswd"

if [[ "$DRY_RUN" = false ]]; then
    if [[ ! -f "$SUDOERS_FILE" ]]; then
        echo "%dev ALL=(ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"
        chmod 440 "$SUDOERS_FILE"
        log "  Файл $SUDOERS_FILE создан (права 440)"
    else
        log "  Файл $SUDOERS_FILE уже существует, пропускаем"
    fi
else
    log "  [DRY-RUN] echo '%dev ALL=(ALL) NOPASSWD: ALL' > $SUDOERS_FILE"
fi

# --- Шаг 4–6: Создание рабочих директорий ---
log "Шаг 4–6/7: Создание рабочих директорий в $WORKDIR_BASE..."

if [[ "$DRY_RUN" = false ]]; then
    mkdir -p "$WORKDIR_BASE"
fi

while IFS=: read -r username _ uid gid _ _ _; do
    if [[ "$uid" -ge "$MIN_UID" ]] && ! is_excluded "$username"; then
        userdir="${WORKDIR_BASE}/${username}_workdir"

        if [[ "$DRY_RUN" = false ]]; then
            mkdir -p "$userdir"
            chown "${username}:${gid}" "$userdir"
            chmod 660 "$userdir"
            log "  ✓ $userdir (владелец: $username:$gid, права: 660)"
        else
            log "  [DRY-RUN] mkdir $userdir, chown $username:$gid, chmod 660"
        fi
    fi
done < /etc/passwd

# --- Шаг 7: ACL на чтение для группы dev ---
log "Шаг 7/7: Настройка ACL — чтение для группы dev на все созданные директории..."

if ! command -v setfacl &>/dev/null; then
    log "  ⚠ ПРЕДУПРЕЖДЕНИЕ: утилита setfacl не найдена. Установите пакет 'acl'."
    log "     apt-get install acl"
fi

while IFS=: read -r username _ uid _ _ _ _; do
    if [[ "$uid" -ge "$MIN_UID" ]] && ! is_excluded "$username"; then
        userdir="${WORKDIR_BASE}/${username}_workdir"

        if [[ "$DRY_RUN" = false ]]; then
            if [[ -d "$userdir" ]]; then
                if command -v setfacl &>/dev/null; then
                    setfacl -m g:dev:r "$userdir" 2>/dev/null || true
                    log "  ✓ ACL на чтение для группы dev на $userdir (setfacl -m g:dev:r)"
                fi
            fi
        else
            log "  [DRY-RUN] setfacl -m g:dev:r $userdir"
        fi
    fi
done < /etc/passwd

log "=============================================="
log "СКРИПТ ЗАВЕРШЁН УСПЕШНО"
log "=============================================="
log "Проверка результатов:"
log "  getent group dev          — посмотреть группу"
log "  cat /etc/sudoers.d/dev-nopasswd — файл sudoers"
log "  ls -la $WORKDIR_BASE        — список директорий"
log "  getfacl <директория>      — ACL на директории"
log "=============================================="
