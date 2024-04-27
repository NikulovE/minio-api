#!/bin/sh
data=$(echo -n '{"accessKey":"'"$MINIO_USER_WRITER"'","secretKey":"'"$MINIO_USER_WRITER_PASSWORD"'"}')
curl --location "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/login" --header 'Content-Type: application/json' --cookie-jar cookies.txt --data "$data"

targetPath="${backet}/"
encodedTargetPath=$(echo -n ${targetPath}| base64 -w 0)

for fileNamePath in download/*; do
  fileName=$(basename $fileNamePath)
  size=$(stat -c%s $fileNamePath)  
  encodedFile=$(echo -n ${targetPath}${fileName} | base64 -w 0)
  curl -X POST "https://${MINIO_HOST}.${DOMAIN_FQDN}/api/v1/buckets/${backet}/objects/upload?prefix=$encodedFile" --cookie cookies.txt  -F "$size=@$fileNamePath"
  echo "Uploaded $fileName"
done