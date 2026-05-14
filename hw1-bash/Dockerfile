FROM ubuntu:22.04

LABEL description="Тестовое окружение для Bash-скрипта setup_users.sh (ДЗ №1 DevOps)"

# Устанавливаем необходимые пакеты
RUN apt-get update && apt-get install -y \
    sudo \
    acl \
    && rm -rf /var/lib/apt/lists/*

# Создаём тестовых «не-системных» пользователей (UID ≥ 1000)
# и задаём им временные пароли
RUN useradd -m -s /bin/bash alice -u 1001 && \
    echo 'alice:test123' | chpasswd && \
    useradd -m -s /bin/bash bob -u 1002 && \
    echo 'bob:test123' | chpasswd && \
    useradd -m -s /bin/bash charlie -u 1003 && \
    echo 'charlie:test123' | chpasswd

# Копируем скрипт
COPY setup_users.sh /usr/local/bin/setup_users.sh
RUN chmod +x /usr/local/bin/setup_users.sh

# По умолчанию — интерактивная оболочка для ручного тестирования
CMD ["/bin/bash"]
