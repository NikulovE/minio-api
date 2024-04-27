Minio deployment manifest + rest api scripts
Here is a Dockerfile for building Minio based on Alpine Linux, a manifest for deploying a Minio server in Kubernetes with post-configuration. 
In the Job, the Minio server connects to Samba DC 4, assigns policies to a domain user and a domain group. 
In API Scripts, commands are collected for curl to create-delete-download operation files for Minio S3 buckets using REST API commands, without the complexities of AWS SDK, AWS4 Signature.

Minio deployment manifest + rest api scripts
Здесь есть Dockefile на сборку Minio на базе Alpine Linux, манифест на разворачивание сервера Minio в Kubernetes с пост настройкой.
В Job сервер Minio подключается к Samba DC 4, назначает политики доменному пользователю и доменной группе
В API Scripts собраны команды для curl на создание-удаление-выгрузку файлов из бакетов Minio S3 с помощью REST API команд, без сложностей с AWS SDK, AWS4 Signature
