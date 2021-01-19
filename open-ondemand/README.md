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


## Configure Shell Application

To configure nodes for remote shell access, yaml files must be placed in the
`/etc/ood/config/clusters.d/` directory.
When configured correctly, any node where a user has SSH permissions can be
accessed through the Open OnDemand web portal.

---
v2:
  metadata:
    title: "mycluster"
    priority: 2
  login:
    host: "mycluster.example1.com"
  job:
    adapter: "slurm"
    cluster: "mycluster"
    bin: "/mycluster/sys/pkg/slurm/std/bin"
  custom:
    xdmod:
      resource_id: 14
    queues:
      - "mycluster"
      - "mycluster-guest"
      - "mycluster-freecycle"
  batch_connect:
    basic:
      script_wrapper: |
        #!/bin/bash
        echo "Hello, World!"
      set_host: "host=$(hostname -s).example1.com"
    vnc:
      script_wrapper: |
        #!/bin/bash
        export var="myvar"
      set_host: "host=$(hostname -s).example1.com"
---
v2:
  metadata:
    title: "node1"
    url: "https://www.chpc.utah.edu/documentation/guides/frisco-nodes.php"
    hidden: false
  login:
    host: "node1.example1.com"
  job:
    adapter: "linux_host"
    submit_host: "node1.example1.com"  # This is the head for a login round robin
    ssh_hosts: # These are the actual login nodes, need to have full host name for the regex to work
      - node1.example1.com
    site_timeout: 7200
    debug: true
    singularity_bin: /uufs/chpc.utah.edu/sys/installdir/singularity3/std/bin/singularity
    singularity_bindpath: /etc,/mnt,/media,/opt,/run,/srv,/usr,/var,/uufs,/scratch
#    singularity_image: /opt/ood/linuxhost_adapter/centos7_lmod.sif
    singularity_image: /uufs/chpc.utah.edu/sys/installdir/ood/centos7_lmod.sif
    # Enabling strict host checking may cause the adapter to fail if the user's known_hosts does not have all the roundrobin hosts
    strict_host_checking: false
    tmux_bin: /usr/bin/tmux
---
