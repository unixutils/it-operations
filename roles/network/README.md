# Network role
 
## What
This role is made to set custom network configuration after the OS installation.
Currently it only supports the creation of routes.
 
## Variables and configured defaults

Example variable:
```
server_network:
  - interface: ens224
    routes:
      - 10.248.93.0/26 via 10.248.54.1 dev ens224
      - 10.248.94.0/26 via 10.248.54.1 dev ens224
```

Included in defaults:
* server\_network: []
(so everything will be skipped per default)
 
## Usage

```
ansible-playbook ../../playbooks/network.yml -l YOUR_SERVER
```
 
## Other remarks
Tested on a RHEL 7.3 system. 
 
## Further reading
