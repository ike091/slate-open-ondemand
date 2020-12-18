# Open OnDemand

Sets up an instance of Open OnDemand.
Authentication is handled through Keycloak.
This application additionally requires a SLATE volume to persist authentication data/configuration.

## Installation:

`slate app get-conf open-ondemand > ood.yaml`

`slate volume create --group <group_name> --cluster <cluster> --size <volume_size> --storageClass <storage_class> volume-name

`slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Create a SLATE volume to persist configuration. (see second command above)
* Modify configuration file to ensure appropriate setup.
	* Set the `SLATE.Cluster.DNSName` value to the DNS name of the cluster the application is being installed on
	* Set the `claimName` value to the name of the previously created SLATE volume.
* Install app with custom configuration onto a SLATE cluster. (see last command above)


## Configuration

The following table lists the configurable parameters of the Open OnDemand application and their default       values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances. |`global`|
|`replicaCount`| The number of replicas to create. |`1`|
|`setupKeycloak`| Runs Keycloak setup script if enabled. |`false`|
|`claimName`| The name of the SLATE volume to store configuration in. |`keycloak-db`| 
|`SLATE.Cluster.DNSName`| DNS name of the cluster the application is deployed on. |`utah-dev.slateci.net`|
