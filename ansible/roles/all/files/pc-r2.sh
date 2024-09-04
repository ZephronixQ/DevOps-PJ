#!/bin/bash

# Целевой IP-адрес для проверки на PC-R1
TARGET_ROUTE_PC_R2="200.200.200.1"

# Функция для проверки и удаления неправильных маршрутов
check_and_delete_route() {
    TARGET_ROUTE=$1

    # Получаем список всех текущих маршрутов по умолчанию
    CURRENT_ROUTES=$(ip route | grep "^default" | awk '{print $3}')

    for ROUTE in $CURRENT_ROUTES; do
        # Проверяем, если маршрут не совпадает с целевым IP
        if [ "$ROUTE" != "$TARGET_ROUTE" ]; then
            echo "Удаляем неправильный маршрут: $ROUTE"
            sudo ip route del default via "$ROUTE"
        else
            echo "Маршрут по умолчанию уже установлен правильно: $ROUTE"
        fi
    done
}

# Выполняем проверку и удаление маршрутов
check_and_delete_route "$TARGET_ROUTE_PC_R2"
