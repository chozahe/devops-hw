# 📘 HW2 — Ansible Playbook

## Задание

Написать Ansible playbook для настройки удалённой машины:

1. Создать пользователя
2. Дать права `sudo`
3. Настроить SSH-авторизацию по ключам
4. Отключить парольную аутентификацию SSH
5. Создать директорию в `/opt/` с правами `660`

---

## Архитектура тестового окружения

Два контейнера в одной Docker-сети:
- **control** — узел с Ansible
- **target** — SSH-сервер, который настраивается

Control подключается к target по SSH (сначала по паролю, потом по ключу) и выполняет playbook.

---

## Файлы

| Файл | Назначение |
|------|-----------|
| `docker-compose.yml` | Docker Compose: control + target |
| `docker/Dockerfile.target` | Образ целевого узла (SSH-сервер) |
| `docker/Dockerfile.control` | Образ управляющего узла (Ansible) |
| `ansible/playbook.yml` | Основной playbook |
| `ansible/inventory/hosts.ini` | Инвентарь (target узел) |
| `ansible/ansible.cfg` | Конфигурация Ansible |
| `ansible/files/ansible_test_key.pub` | Публичный SSH-ключ для авторизации |
| `run_demo.sh` | Демонстрация: сборка → playbook → проверка |

---

## Запуск демонстрации

```bash
cd hw2-ansible
./run_demo.sh
```

## Ручной запуск

```bash
docker compose build
docker compose up -d target
docker compose run --rm control bash
# Внутри control:
ansible-playbook -i inventory/hosts.ini playbook.yml
```

## Примечания

- Парольная аутентификация отключается — после этого доступ только по SSH-ключу.
- В тестовом окружении используется временный пользователь `ansible`.
- Права `660` на директорию — см. [замечание в HW1](../hw1-bash/README.md).
