# Open OnDemand Development Notes



## Questions

* Immediate vs. WaitForFirstConsumer SLATE volume bindings?


## Volume Setup

`utah-dev` volume creation: `slate volume create --group slate-dev --cluster utah-dev --size 50M --storageClass local-path keycloak-db`

This will create the volume in the `slate-group-slate-dev` namespace. 
For the Keycloak container to properly claim the volume, it will need to be installed in the same group. 
If installing directly with Helm, use `-n slate-group-slate-dev`. 
Otherwise, as long as the volume and application are installed in the same SLATE group, everything will work.

Consult individual cluster documentation for information about supported storage classes. (`slate cluster info <cluster_name>`)


## SLATE Setup:

`slate app get-conf open-ondemand > ood.yaml`

`slate volume create --group <group_name> --cluster <cluster> --size <volume_size> --storageClass <storage_class> volume-name

`slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml`



* Retrieve default configuration file. (see first command above)
* Create a SLATE volume to persist configuration. (see second command above)
* Modify configuration file to ensure appropriate setup.
	* Set the `SLATE.Cluster.DNSName` value to the DNS name of the cluster the application is being installed on
	* Set the `claimName` value to the name of the previously created SLATE volume.
* Install app with custom configuration onto a SLATE cluster. (see last command above)

