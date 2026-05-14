# 🛠 DevOps — Домашние задания

Студент: **Саша Емочкин**  
Группа: *учебная*  
Предмет: DevOps

---

## Структура репозитория

| Задание | Папка | Описание |
|---------|-------|----------|
| **HW1** | [`hw1-bash/`](./hw1-bash/) | Bash-скрипт: создание группы `dev`, sudo без пароля, рабочие директории |
| **HW2** | [`hw2-ansible/`](./hw2-ansible/) | Ansible Playbook: создание пользователя, sudo, SSH-ключи, отключение паролей |
| **HW3** | [`hw3-ansible-roles/`](./hw3-ansible-roles/) | Ansible Roles + Molecule: роли `user_setup` и `ssh_setup`, тестирование |

---

## Безопасность

Все задания изолированы в Docker-контейнерах. Ни один скрипт не затрагивает хост-систему.

| Задание | Изоляция |
|---------|----------|
| HW1 | Docker-контейнер с тестовыми пользователями |
| HW2 | Docker Compose: control-узел (Ansible) + target-узел (SSH-сервер) |
| HW3 | Molecule с Docker-драйвером |

---

## Быстрый старт

```bash
# HW1 — Bash-скрипт
cd hw1-bash && ./run_demo.sh

# HW2 — Ansible Playbook
cd hw2-ansible && ./run_demo.sh

# HW3 — Ansible Roles + Molecule
cd hw3-ansible-roles && ./run_demo.sh
```

---

## Требования

- **Docker** и **Docker Compose** — для всех заданий
- **Python 3** + `molecule` и `molecule-docker` — для HW3

Установка molecule:
```bash
pip install molecule molecule-docker
```
