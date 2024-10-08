# Список задач

Этот файл содержит список задач, которые планируется выполнить в будущем для проекта "DevOps-PJ".

## Планируемые релизы

### Версия 1.0.0 - Разворачивание инфраструктуры на виртуальных машин (VM)

#### 1. Создание файла `init.md`
- Добавление автоматического поднятия VM кластера.
- Установка всех необходимых пакетов для работы с проектом "DevOps-PJ".

#### 3. Ansible Playbook для администрирования Linux
- Создание и настройка Ansible Playbook для автоматизации задач администрирования Linux:
  - Настройка IP-адресов.
  - Конфигурация DHCP-сервера.
  - Настройка маршрутизации.
  - Создание и настройка VPN.
  - Конфигурация SSH.
  - Установка и настройка DNS.
  - Конфигурация NTP.
  - Установка и настройка CUPS.
  - Конфигурация NFS.
  - Установка и настройка ClamAV.
  - Настройка резервного копирования.
  - Конфигурация Firewalld и Iptables.
  - Автоматизация административных задач с использованием скриптов на Rust, Python и Bash.

#### 4. Интеграция с CI/CD
- Настройка интеграции с GitLab CI/CD для автоматического развертывания инфраструктуры и конфигурации серверов.

#### 5. Мониторинг и логирование
- Внедрение мониторинга и логирования для серверов и сервисов:
  - Внедрение Prometheus для сбора метрик.
  - Внедрение Grafana для визуализации данных.
  - Внедрение Loki для централизованного логирования.

#### 6. Компоненты проекта
- Настройка и интеграция следующих компонентов:
  - **Rust**: Бэкенд-приложение.
  - **Iggy**: Очередь сообщений.
  - **Nginx**: Веб-сервер.
  - **Redis**: Кэширование.
  - **PostgreSQL**: База данных.
  - **GitLab**: CI/CD.
  - **Docker**: Контейнеризация приложений.
  - **Docker Compose**: Оркестрация многоконтейнерных Docker приложений.

#### 7. Kubernetes и Helm
- Подготовка к развертыванию микросервисной архитектуры:
  - Поднятие Kubernetes кластера на локальных VM с использованием Minikube.
  - Создание Helm chart для каждого компонента приложения.
  - Настройка Helm для автоматического развертывания и управления приложениями в Kubernetes.
  - Интеграция с GitLab CI/CD для автоматического развертывания в Kubernetes.

### Версия 2.0.0 - Разворачивание инфраструктуры на Yandex.Cloud

#### 1. Подготовка инфраструктуры Yandex.Cloud
- Настройка доступа к Yandex.Cloud.
- Создание и настройка сервисного аккаунта и ключей для автоматического доступа.

#### 2. Обновление Terraform конфигурации
- Создание `main.tf` для работы с Yandex.Cloud:
  - Создание 5 виртуальных машин в Yandex.Cloud.
  - Назначение IP-адресов и портов.
  - Настройка SSH-доступа.

#### 3. Обновление Ansible Playbook
- Обновление Ansible инвентаря и playbook для работы с VM в Yandex.Cloud.
- Настройка автоматизации конфигурации и управления новыми VM.

#### 4. Автоматизация развёртывания и настройки
- Создание CI/CD pipeline в GitLab для автоматического развёртывания инфраструктуры в Yandex.Cloud.
- Настройка автоматического развертывания приложений и сервисов.

#### 5. Интеграция с компонентами проекта
- Настройка и интеграция такие компоненты, как: Prometheus, Grafana, Loki, Rust, Iggy, Nginx, Redis, PostgreSQL, и Docker.

#### 6. Kubernetes и Helm в Yandex.Cloud
- Подготовка к развертыванию микросервисной архитектуры в Yandex.Cloud:
  - Настройка Kubernetes кластера в Yandex.Cloud.
  - Обновление Helm chart для каждого компонента приложения для работы в Yandex.Cloud.
  - Интеграция с GitLab CI/CD для автоматического развертывания в Kubernetes на Yandex.Cloud.

## Ваши предложения и идеи

Если у вас есть идеи или предложения по улучшению проекта, пожалуйста, создайте новый Issue или Pull Request в репозитории.
