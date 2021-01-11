#! /bin/bash

# Sets up Keycloak to allow Open OnDemand to authenticate through it.


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
# client_id="ondemand-dev.hpc.osc.edu"
client_id="ondemand.utah-dev.slateci.net"

# Create ondemand client
$keycloak create clients -r ondemand -s clientId=$client_id -s enabled=true -s protocol=openid-connect -s directAccessGrantsEnabled=false

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

echo $client_secret > /shared/client-secret





# Things to change:

# Access type: confidential
# Authorization: enabled
# Valid redirect URIs (2)
# * https://global.ondemand.utah-dev.slateci.net
# * https://global.ondemand.utah-dev.slateci.net/oidc

# TODO: Verify http names are all correct, check json for redirect uri formatting
# $keycloak create clients -r ondemand -s clientId=$client_id -s enabled=true -s protocol=openid-connect -s directAccessGrantsEnabled=false -s serviceAccountsEnabled=true



# TODO: create environment variable that matches instance name and cluster DNS name
# TODO: store first password in another environment variable so that it doesn't get overwritten


