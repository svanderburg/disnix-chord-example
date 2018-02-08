disnix-chord-example
====================
A public Disnix example deploying a Distributed Hash Table (DHT) consisting of a
network of Chord nodes. It has been based on
[OpenChord](http://open-chord.sourceforge.net).

Usage
=====
There are three ways to try to deploy this example.

The `deployment/DistributedDeployment` folder contains all
neccessary Disnix models, such as a services, infrastructure and distribution
models required for deployment.

Deployment using Disnix in a heterogeneous network
--------------------------------------------------
For this scenario only installation of the basic Disnix toolset is required.

First, you must manually install a network of machines running the Disnix
service. Then you must adapt the infrastructure model to match to properties of
your network and the distribution model to map the services to the right
machines.

We can deploy the system by running the following command:

    $ disnix-env -s services.nix -i infrastructure.nix -d distribution.nix

Hybrid deployment of NixOS infrastructure and services using DisnixOS
---------------------------------------------------------------------
For this scenario you need to install a network of NixOS machines, running the
Disnix service. This can be done by enabling the following configuration option
in each `/etc/nixos/configuration.nix` file:

    $ services.disnix.enable = true;

You may also need to adapt the NixOS configurations to which the `network.nix`
model is referring, so that they will match the actual system configurations.

The system including its underlying infrastructure can be deployed by using the
`disnixos-env` command:

    $ disnixos-env -s services.nix -n network.nix -d distribution.nix

Deployment using the NixOS test driver
--------------------------------------
This system can be deployed without adapting any of the models in
`deployment/DistributedDeployment`. By running the following instruction, the
system can be deployed in a network of virtual machines:

    $ disnixos-vm-env -s services.nix -n network.nix -d distribution.nix

The disadvantage of using the virtualization extension is that no upgrades can be
performed and thus the locking mechanism cannot be used.

Deployment using NixOps for infrastructure and Disnix for service deployment
----------------------------------------------------------------------------
It's also possible to use NixOps for deploying the infrastructure (machines) and
let Disnix do the deployment of the services to these machines.

A virtualbox network can be deployed as follows:

    $ nixops create ./network.nix ./network-virtualbox.nix -d vboxtest
    $ nixops deploy -d vboxtest

The system can be deployed as follows:

    $ disnixos-env -s services.nix -n network.nix -d distribution.nix --use-nixops

Testing
=======
To test the Chord network, you can connect to any machine in the network, e.g.
through NixOps or a "plain" SSH connection:

```bash
$ nixops ssh -d vbox test1
```

Start the OpenChord console by running the following command:

```bash
$ /nix/var/nix/profiles/disnix/default/bin/openchord-console
```

We can join any Chord node deployed by Disnix as a bootstrap node:

```
> joinN -port 9000 -bootstrap localhost:8001
```

We can see the references as follows:

```
> refsN
```

The above command shows you one predecessor and all the successors of the
current node in the ring.

We can also add an object to the distributed hash table and view the table's
content:

```
> insertN -key test -value test
> entriesN
```

For more details on how to use the console, consult the OpenChord manual that
comes with the package:

```bash
$ nix-build deployment/top-level/all-packages.nix -A openchord
$ okular result/share/doc/openchord/manual/manual.pdf
```

License
=======
The `ChordServer` package uses the OpenChord API that is
[GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html) licensed.
As a result, the `ChordServer` package that can be found in the `src/` folder is
covered by the same license. See the license header in the Java class for more
information.

The remainder of this repository is [MIT](https://opensource.org/licenses/MIT)
licensed.
