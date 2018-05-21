# Mulitpath role
 
## What
This role generates multipath.conf and enables multipathd.
It should detect paths and configure mulitipath devices with standard options.
 
## Variables and configured defaults
Defaults for the mpathconf command options:
```
with_module: y
find_multipaths: y
user_friendly_names: y
# warning: multipathd won't be started if you disable this one:
with_multipathd: y
```

## Usage

```
> ansible-playbook ../../playbooks/multipath.yml -l YOUR_SERVER
```

## Other remarks

 
## Further reading

* https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/DM_Multipath/index.html 
