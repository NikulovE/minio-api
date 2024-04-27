#!/bin/sh
data=$(echo -n '{"accessKey":"'"$MINIO_USER_WRITER"'","secretKey":"'"$MINIO_USER_WRITER_PASSWORD"'"}')
curl --location "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/login" --header 'Content-Type: application/json' --cookie-jar cookies.txt --data "$data"

targetPath="${backet}/"
encodedTargetPath=$(echo -n ${targetPath}| base64 -w 0)
curl -X DELETE "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/buckets/${backet}/objects?prefix=$encodedTargetPath&all_versions=false&bypass=false&recursive=true" --cookie cookies.txt