#! /bin/bash

# Uses the keycloak-cli to setup LDAP and Kerberos authentication through keycloak.
# Currently needs to be run inside Keycloak container, in directory containing kcadm.sh script.


# Try to setup API access credentials
/opt/keycloak-4.8.3.Final/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user    admin --password KEYCLOAKPASS

# Retry until command succeeds
while [ $? -ne 0 ]; do
	/opt/keycloak-4.8.3.Final/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password KEYCLOAKPASS
	# wait ten seconds before trying again
	sleep 10
done

# Setup credentials
# ./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password KEYCLOAKPASS
# Create ondemand realm
# ./kcadm.sh create realms -s realm=ondemand -s enabled=true --no-config --server http://localhost:8080/auth --realm   master --user admin --password KEYCLOAKPASS


# Create realm
./kcadm.sh create realms -s realm=test -s enabled=true


# TODO: fix login with email and remember me settings


# Get information about ondemand realm
# ./kcadm.sh get realms/ondemand --no-config --server http://localhost:8080/auth --realm master --user admin --        password KEYCLOAKPASS
# Create a new client
# ./kcadm.sh create clients -r ondemand -s clientId=myapp -s enabled=true --no-config --server http://localhost:8080/  auth --realm master --user admin --password KEYCLOAKPASS

