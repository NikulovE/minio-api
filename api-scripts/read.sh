#!/bin/sh
data=$(echo -n '{"accessKey":"'"$MINIO_USER"'","secretKey":"'"$MINIO_USER_PASSWORD"'"}')
curl --location "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/login" --header 'Content-Type: application/json' --cookie-jar cookies.txt --data "$data"

targetPath="iaas-base/RPM/"
encodedTargetPath=$(echo -n ${targetPath}| base64 -w 0)

response=$(curl -X GET "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/buckets/${backet}/objects?prefix=$encodedTargetPath&all_versions=false&bypass=false&recursive=true" --cookie cookies.txt)

echo "$response" | jq -r '.objects[].name' | while read -r name; do
  encodedName=$(echo -n $name | base64 -w 0)
  curl -X GET "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/buckets/${backet}/objects/download?prefix=$encodedName&version_id=null" --cookie cookies.txt -o "$(basename "$name")"
done
