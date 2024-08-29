#!/bin/bash

# Функция для проверки и установки пакета
check_and_install() {
    local package="$1"
    dpkg -l | grep -qw "$package"
    if [ $? -ne 0 ]; then
        echo "Пакет $package не найден. Устанавливаем..."
        sudo apt-get install -y "$package"
    else
        echo "Пакет $package уже установлен."
    fi
}

# Обновление списка пакетов
echo "Обновление списка пакетов..."
sudo apt-get update > /dev/null 2>&1

# Проверка и установка python3-requests
check_and_install "python3-requests"

# Проверка и установка python3-pip
check_and_install "python3-pip"

echo "Проверка и установка завершены."
