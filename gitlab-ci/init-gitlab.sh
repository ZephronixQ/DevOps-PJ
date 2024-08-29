#!/bin/bash

# Проверка наличия необходимых пакетов и их установка при необходимости на удалённом хосте
check_and_install_remote() {
    local ip=$1
    local user=$2
    local password=$3
    local pkg=$4
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$ip" << EOF
        if ! command -v $pkg &> /dev/null; then
            echo "[ ] $pkg не установлен. Устанавливаю..."
            sudo apt-get update
            sudo apt-get install -y $pkg
        else
            echo "[*] $pkg уже установлен."
        fi
EOF
}

# Установка и запуск GitLab Runner на удалённом хосте
install_and_start_gitlab_runner() {
    local ip=$1
    local user=$2
    local password=$3
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$ip" << EOF
        if ! command -v gitlab-runner &> /dev/null; then
            echo "[ ] GitLab Runner не найден. Устанавливаю..."
            sudo wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
            sudo chmod +x /usr/local/bin/gitlab-runner
            sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash || echo "Пользователь gitlab-runner уже существует."
            sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
            sudo gitlab-runner start
        else
            echo "[*] GitLab Runner уже установлен."
            sudo gitlab-runner restart
        fi
EOF
}

# Генерация RSA ключа на удалённом хосте
generate_ssh_key_remote() {
    local ip=$1
    local user=$2
    local password=$3
    local key_path=$4
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$ip" << EOF
        if [ ! -f "$key_path" ]; then
            ssh-keygen -f "$key_path" -N "" || { echo "Не удалось создать RSA ключ"; exit 1; }
            echo "[*] RSA ключ успешно создан: $key_path"
        else
            echo "[*] RSA ключ уже существует: $key_path"
        fi
EOF
}

# Регистрация GitLab Runner на удалённом хосте
register_gitlab_runner_remote() {
    local ip=$1
    local user=$2
    local password=$3
    local registration_token=$4
    local key_path=$5
    local tag=$6
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$ip" << EOF
        sudo gitlab-runner register --non-interactive \
          --url 'https://gitlab.com/' \
          --registration-token '$registration_token' \
          --tag-list '$tag' \
          --executor 'ssh' \
          --ssh-host '$ip' \
          --ssh-port '22' \
          --ssh-user '$user' \
          --ssh-password '$password' \
          --ssh-identity-file '$key_path'
EOF
}

# Добавление IP сервера в файл known_hosts на удалённом хосте
add_known_host_remote() {
    local ip=$1
    local user=$2
    local password=$3
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$ip" << EOF
        mkdir -p ~/.ssh
        ssh-keyscan -H $ip >> ~/.ssh/known_hosts
EOF
}

# Добавление собственного id_rsa в файл authorized_keys на удалённом хосте
add_authorized_key_remote() {
    local ip=$1
    local user=$2
    local password=$3
    local key_path=$4
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user@$ip" << EOF
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        cat $key_path.pub >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
EOF
}

# Переменные
PROJECT_NAME="DevOps-PJ"
GITLAB_API="https://gitlab.com/api/v4"
IP_FILE="../VMware/ip.txt"
KEY_PATH="/root/.ssh/id_rsa"
SSH_USER="root"
SSH_PASSWORD="root"

# Получаем токен из временного файла
source "$TEMP_FILE"

# Получаем информацию о проекте
PROJECT_INFO=$(curl --silent --header "Private-Token: $TOKEN" "$GITLAB_API/projects?search=$PROJECT_NAME")

# Проверяем, получен ли проект
if [ "$(echo "$PROJECT_INFO" | jq -r '.[0]')" == "null" ]; then
    echo "[ ] Проект не найден. Убедитесь, что имя проекта верное."
    exit 1
fi

# Извлекаем ID проекта
PROJECT_ID=$(echo "$PROJECT_INFO" | jq -r '.[0].id')

# Получаем информацию о проекте
PROJECT_DATA=$(curl --silent --header "Private-Token: $TOKEN" "$GITLAB_API/projects/$PROJECT_ID")

# Извлекаем регистрационный токен
REGISTRATION_TOKEN=$(echo "$PROJECT_DATA" | jq -r '.runners_token')

if [ "$REGISTRATION_TOKEN" == "null" ]; then
    echo "[ ] Не удалось получить токен регистрации. Проверьте настройки проекта."
    exit 1
fi

echo "[*] Регистрационный токен: $REGISTRATION_TOKEN"

# Чтение IP-адресов из файла
if [ ! -f "$IP_FILE" ]; then
    echo "[ ] Файл $IP_FILE не найден."
    exit 1
fi

# Определение тегов для IP-адресов
TAG="r0.server"

# Переменная для хранения последнего IP
LAST_IP=""

# Чтение файла построчно
while IFS= read -r IP; do
    LAST_IP="$IP"
done < "$IP_FILE"

# Теперь выполняем действия для последнего IP
echo "[*] Обработка последнего IP: $LAST_IP"

# Проверка и установка необходимых пакетов на удалённом хосте
check_and_install_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "curl"
check_and_install_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "jq"
check_and_install_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "sshpass"
check_and_install_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "git"
check_and_install_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "ansible"

# Генерация RSA ключа на удалённом хосте
generate_ssh_key_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "$KEY_PATH"

# Установка и запуск GitLab Runner на удалённом хосте
install_and_start_gitlab_runner "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD"

# Регистрация нового runner
register_gitlab_runner_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "$REGISTRATION_TOKEN" "$KEY_PATH" "$TAG"

# Добавление IP сервера в файл known_hosts на удалённом хосте
add_known_host_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD"

# Добавление собственного id_rsa в файл authorized_keys на удалённом хосте
add_authorized_key_remote "$LAST_IP" "$SSH_USER" "$SSH_PASSWORD" "$KEY_PATH"

# Передача файла IP-адресов на последний сервер
sshpass -p "$SSH_PASSWORD" scp "$IP_FILE" "$SSH_USER@$LAST_IP:/root/ip.txt"

# Использование sshpass для автоматизации ввода пароля и выполнения команд на последнем сервере
sshpass -p "$SSH_PASSWORD" ssh "$SSH_USER@$LAST_IP" 'bash -s' <<EOF

# Очистка файла known_hosts, если требуется
> ~/.ssh/known_hosts

# Чтение IP-адресов из файла и добавление их в known_hosts
while IFS= read -r IP; do
    # Проверка, чтобы IP не был пустым
    if [ -n "\$IP" ]; then
        ssh-keyscan -H "\$IP" >> ~/.ssh/known_hosts
    fi
done < /root/ip.txt

# Чтение IP-адресов из файла и добавление SSH-ключей на каждый IP
while IFS= read -r IP; do
    # Проверка, чтобы IP не был пустым
    if [ -n "\$IP" ]; then
        sshpass -p "$SSH_PASSWORD" ssh-copy-id -i /root/.ssh/id_rsa.pub root@"\$IP"
    fi
done < /root/ip.txt
EOF

echo "[*] Завершена обработка IP: $LAST_IP" && echo "[*] Настройка GitLab Runner завершена."

# Установка неоюходимых PIP пакетов
./init-pip.sh