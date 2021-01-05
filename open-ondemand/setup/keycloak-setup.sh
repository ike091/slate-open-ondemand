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

# Setup credentials
# ./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password KEYCLOAKPASS
# Create ondemand realm
# ./kcadm.sh create realms -s realm=ondemand -s enabled=true --no-config --server http://localhost:8080/auth --realm   master --user admin --password KEYCLOAKPASS


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

client_id="ondemand-dev.hpc.osc.edu"

$keycloak create client -r ondemand -s clientId=$client_id -s enabled=true -s clientProtocol=openid-connect


# TODO: Get client-id
echo $client_id > /shared/client-id

# TODO: Get the client secret to use with OnDemand installation
# Select the “Credentials” tab of the “Client” you are viewing i.e. “Clients >> ondemand-dev.hpc.osc.edu”
# Copy the value for “secret” for future use in this tutorial (and keep it secure).

$keycloak get clients/$client_id/client-secret > /shared/client-secret

