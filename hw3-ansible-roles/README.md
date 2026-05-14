# 🧪 HW3 — Ansible Roles + Molecule

## Задание

Реализовать ту же задачу, что и в HW2, но с использованием **Ansible Roles**:

- Роль `user_setup` — создание пользователей, групп, sudo, рабочих директорий
- Роль `ssh_setup` — SSH-ключи и отключение парольной аутентификации
- Пользователи и их ключи задаются через `vars`
- Тестирование ролей через **Molecule** с драйвером Docker

---

## Структура

```
hw3-ansible-roles/
├── ansible.cfg
├── playbook.yml
├── roles/
│   ├── user_setup/
│   │   ├── tasks/main.yml
│   │   ├── vars/main.yml           # ← пользователи
│   │   ├── defaults/main.yml
│   │   └── meta/main.yml
│   └── ssh_setup/
│       ├── tasks/main.yml
│       ├── vars/main.yml           # ← SSH-ключи
│       ├── handlers/main.yml
│       └── meta/main.yml
├── molecule/default/
│   ├── molecule.yml                # driver: docker
│   ├── converge.yml                # playbook для развёртывания
│   └── verify.yml                  # тесты (assert)
└── run_demo.sh
```

---

## Запуск

```bash
cd hw3-ansible-roles

# Установка molecule
pip install molecule molecule-docker

# Полный цикл: create → converge → verify → destroy
./run_demo.sh

# По шагам:
./run_demo.sh converge
./run_demo.sh verify
./run_demo.sh destroy
```

## Ручной запуск Molecule

```bash
cd hw3-ansible-roles/molecule/default
molecule test        # полный тест
molecule converge    # только развёртывание
molecule verify      # только проверка
molecule login       # зайти в контейнер
molecule destroy     # удалить
```

## Примечания

- Molecule использует Docker-драйвер
- Образ: `geerlingguy/docker-ubuntu2204-ansible` (с systemd)
- Права `660` на директорию — см. [замечание в HW1](../hw1-bash/README.md)
