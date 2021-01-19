#! /bin/bash

# Sets up Keycloak to allow Open OnDemand to authenticate through it.

# TODO: ensure that this script can safely be run twice
# TODO: save Keycloak admin password in a SLATE secret somehow?


# Path to jboss-cli tool:
jboss_cli="/opt/jboss/keycloak/bin/jboss-cli.sh"

# Enable proxying to Keycloak:
$jboss_cli 'embed-server,/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)'
$jboss_cli 'embed-server,/socket-binding-group=standard-sockets/socket-binding=proxy-https:add(port=443)'
$jboss_cli 'embed-server,/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=proxy-https)'


# Path to keycloak-cli tool:
keycloak="/opt/jboss/keycloak/bin/kcadm.sh"

# Setup credentials for connection to API
user="admin"
password=$KEYCLOAK_PASSWORD
realm="master"
server="http://localhost:8080/auth"

# Try to setup API access credentials and retry up to five times
n=0
until [ "$n" -ge 5 ]
do
	$keycloak config credentials --server $server --realm $realm --user $user --password $password && break
	n=$((n+1)) 
	sleep 5
done

# Create Open-OnDemand realm
$keycloak create realms -s realm=ondemand -s enabled=true

# TODO: adjust login parameters in ondemand realm ("remember me: ON", "login with email: OFF")


# Open OnDemand client id
client_id=$SLATE_INSTANCE_NAME.ondemand.$SLATE_CLUSTER_NAME

# OnDemand URIs to redirect to Keycloak
redirect_uris="[\"https://$SLATE_INSTANCE_NAME.ondemand.$SLATE_CLUSTER_NAME\",\"https://$SLATE_INSTANCE_NAME.ondemand.$SLATE_CLUSTER_NAME/oidc\"]"

# Create Open-OnDemand Keycloak client
$keycloak create clients -r ondemand -s clientId=$client_id -s enabled=true -s publicClient=false -s protocol=openid-connect -s directAccessGrantsEnabled=false -s serviceAccountsEnabled=true -s redirectUris=$redirect_uris -s authorizationServicesEnabled=true

# Store useful regex pattern
client_id_pattern={\"id\":\"[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\",\"clientId\":\"$client_id\"}

# Store useful regex pattern
secret_id_pattern=[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}

# Get other id field
id=$($keycloak get clients -r ondemand --fields clientId,id | tr -d " \t\n\r" | grep -o -E $client_id_pattern | grep -o -E $secret_id_pattern)

# Write client_id to a file in shared volume
echo $client_id > /shared/id

# Get the client secret to use with OnDemand installation
client_secret=$($keycloak get clients/$id/client-secret -r ondemand | tr -d " \t\n\r" | grep -o -E $secret_id_pattern)

# Write client_secret to a file in shared volume
echo $client_secret > /shared/client-secret

# TODO: configure LDAP (https://osc.github.io/ood-documentation/latest/authentication/tutorial-oidc-keycloak-rhel7/configure-keycloak-webui.html)
$keycloak create components -r ondemand -s name=kerberos-ldap-provider -s providerId=ldap -s providerType=org.keycloak.storage.UserStorageProvider -s 'config.priority=["0"]' -s 'config.enabled=["true"]' -s 'config.fullSyncPeriod=["-1"]' -s 'config.changedSyncPeriod=["-1"]' -s 'config.cachePolicy=["DEFAULT"]' -s 'config.batchSizeForSync=["1000"]' -s 'config.editMode=["READ_ONLY"]' -s 'config.syncRegistrations=["false"]' -s 'config.vendor=["other"]' -s 'config.usernameLDAPAttribute=["uid"]' -s 'config.rdnLDAPAttribute=["uid"]' -s 'config.uuidLDAPAttribute=["uidNumber"]' -s 'config.userObjectClasses=["inetOrgPerson, organizationalPerson"]' -s 'config.connectionUrl=["ldap://ldap.chpc.utah.edu"]' -s 'config.usersDn=["ou=People,dc=chpc,dc=utah,dc=edu"]' -s 'config.authType=["none"]' -s 'config.searchScope=["1"]' -s 'config.useTruststoreSpi=["ldapsOnly"]' -s 'config.connectionPooling=["true"]' -s 'config.pagination=["true"]' -s 'config.allowKerberosAuthentication=["true"]' -s 'config.serverPrincipal=["HTTP/utah-dev.chpc.utah.edu@AD.UTAH.EDU"]' -s 'config.keyTab=["/etc/krb5.keytab"]' -s 'config.kerberosRealm=["AD.UTAH.EDU"]' -s 'config.debug=["true"]' -s 'config.useKerberosForPasswordAuthentication=["true"]' -s 'config.importEnabled=["true"]'

