#! /bin/bash

# Uses the keycloak-cli to setup LDAP and Kerberos authentication through keycloak.

# Path to keycloak-cli tool:
keycloak="/opt/keycloak-4.8.3.Final/bin/kcadm.sh"

# TODO: Make sure volume exists before running this command

# Setup credentials for connection to API
user="admin"
# password=`cat /secret-volume/password`
password="KEYCLOAKPASS"
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

# Create ondemand realm
$keycloak create realms -s realm=ondemand -s enabled=true

# TODO: adjust login parameters in ondemand realm ("remember me: ON", "login with email: OFF")

# TODO: configure LDAP (https://osc.github.io/ood-documentation/latest/authentication/tutorial-oidc-keycloak-rhel7/configure-keycloak-webui.html)

# TODO: Add OnDemand as a client
# client id: ondemand-dev.hpc.osc.edu
# client protocol: openid-connect
# access type: confidential
# direct access grants enabled: off
# valid redirect URIs: https://ondemand-dev.hpc.osc.edu/oidc, https://ondemand-dev.hpc.osc.edu # TODO: make sure these are correct

# Open OnDemand client id
client_id="ondemand-dev.hpc.osc.edu"

# Create ondemand client
$keycloak create clients -r ondemand -s clientId=$client_id -s enabled=true -s protocol=openid-connect -s directAccessGrantsEnabled=false

# Store useful regex pattern
client_id_pattern={\"id\":\"[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}\",\"clientId\":\"$client_id\"}

# Store useful regex pattern
secret_id_pattern=[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}

# Get other id field and write it to a file
id=$($keycloak get clients -r ondemand --fields clientId,id | tr -d " \t\n\r" | grep -o -E $client_id_pattern | grep -o -E $secret_id_pattern)

echo $id > /shared/id


# Get the client secret to use with OnDemand installation
client_secret=$($keycloak get clients/$id/client-secret -r ondemand | tr -d " \t\n\r" | grep -o -E $secret_id_pattern)

echo $client_secret > /shared/client-secret

