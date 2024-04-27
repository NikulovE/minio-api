#!/bin/sh
update-ca-certificates
until samba-tool ou list -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD} | grep -q "${DOMAIN_GROUP_PREFIX}Users"; do
    echo waiting for domain controller
    sleep 2
done
echo "Lets check ad service account connector is exists or not"
{
    check=$(samba-tool user show ${DOMAIN_MINIO_SVC_CONNECTOR} -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD})
    if [ "$check" ]; then
        echo "service account is exists already exists"
    else
        echo "service account does not exists"
        samba-tool user create ${DOMAIN_MINIO_SVC_CONNECTOR} ${DOMAIN_MINIO_SVC_CONNECTOR_PASSWORD} -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}
        samba-tool user setexpiry --noexpiry ${DOMAIN_MINIO_SVC_CONNECTOR}
    fi
} || {
    echo "Произошла ошибка при выполнении скрипта создания ad service account"
    samba-tool user create ${DOMAIN_MINIO_SVC_CONNECTOR} ${DOMAIN_MINIO_SVC_CONNECTOR_PASSWORD} -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}
    samba-tool user setexpiry --noexpiry ${DOMAIN_MINIO_SVC_CONNECTOR}
}
echo "Finished ad service connector account"
samba-tool user create ${DOMAIN_MINIO_USER_WRITER} ${DOMAIN_MINIO_USER_WRITER_PASSWORD} --userou=OU=${DOMAIN_GROUP_PREFIX}Users -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}
samba-tool user setexpiry --noexpiry ${DOMAIN_MINIO_USER_WRITER}

samba-tool user create ${DOMAIN_MINIO_USER_READER} ${DOMAIN_MINIO_USER_READER_PASSWORD} --userou=OU=${DOMAIN_GROUP_PREFIX}Users -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}
samba-tool user setexpiry --noexpiry ${DOMAIN_MINIO_USER_READER}

samba-tool group add minio-rw_users --groupou="OU=${DOMAIN_GROUP_PREFIX}Groups" -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}
samba-tool group add minio-r_users --groupou="OU=${DOMAIN_GROUP_PREFIX}Groups" -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}

samba-tool group addmembers minio-rw_users $DOMAIN_MINIO_USER_WRITER -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}
samba-tool group addmembers minio-r_users $DOMAIN_MINIO_USER_READER -H ldap://${SAMBA_HOST} -U Administrator%${DOMAIN_ADMIN_PASSWORD}


while ! mcli alias set minio https://"${MINIO}":9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"; do sleep 1; done
mcli mb minio/shared
mcli mb minio/tenant

mcli idp ldap add minio server_addr="$MINIO_IDENTITY_LDAP_SERVER_ADDR" lookup_bind_dn="$MINIO_IDENTITY_LDAP_LOOKUP_BIND_DN" lookup_bind_password="$MINIO_IDENTITY_LDAP_LOOKUP_BIND_PASSWORD" user_dn_search_base_dn="$MINIO_IDENTITY_LDAP_USER_DN_SEARCH_BASE_DN" user_dn_search_filter="$MINIO_IDENTITY_LDAP_USER_DN_SEARCH_FILTER" group_search_base_dn="$MINIO_IDENTITY_LDAP_GROUP_SEARCH_BASE_DN" group_search_filter="$MINIO_IDENTITY_LDAP_GROUP_SEARCH_FILTER"
mcli admin service restart minio

mcli idp ldap enable  minio
mcli admin service restart minio
mcli idp ldap policy attach minio consoleAdmin --user="CN=${DOMAIN_GLOBAL_ADMIN},OU=${DOMAIN_GROUP_PREFIX}Users,$DOMAIN_DN_PATH"

mcli idp ldap policy attach minio readwrite --user="CN=${DOMAIN_MINIO_USER_WRITER},OU=${DOMAIN_GROUP_PREFIX}Users,$DOMAIN_DN_PATH"
mcli idp ldap policy attach minio readonly --user="CN=${DOMAIN_MINIO_USER_READER},OU=${DOMAIN_GROUP_PREFIX}Users,$DOMAIN_DN_PATH"

mcli idp ldap policy attach minio readwrite --group="CN=minio-rw_users,OU=${DOMAIN_GROUP_PREFIX}Groups,$DOMAIN_DN_PATH"
mcli idp ldap policy attach minio readonly --group="CN=minio-r_users,OU=${DOMAIN_GROUP_PREFIX}Groups,$DOMAIN_DN_PATH"