# k8s-git-repo

k8s-git-repo is a utility container and k8s service + replication
controller definition.

Some of our workflows require a private on prem git repo.

This beta test is to assist management of a distributable git repo
with kubernetes.

This iteration hasn't enabled a persistant data store, but could be
persisted by using a node label and pin the instance to a node.

A future version will support a persistant store.

```
## test repo container name k8s-git-repo
## For a docker based test . . .
# .bashrc function for docker ip
function docker-ip
{
    if [[ -n ${1} ]]; then
        docker inspect --format='{{ .NetworkSettings.IPAddress }}' ${1}
    else
        echo usage: docker-ip cid
    fi
}
```

### Example init script


```
# create the script 
touch    mkrepo
chmod +x mkrepo
```

```
#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
# Derive repo name from directory.  Override if the repo of this git
# directory isn't the same as the directory's base name.
repo=${dir##*/}
host=k8s-git-repo

# .ssh/config entry to enable simple access

# Change port to 22 and comment hostname if using k8s yaml definition.
# and adding the master [ or host like k8s-master-01 ] to /etc/hosts
# If accessing remotely via a docker host, maybe mapping -p 2222:22
# . . .

# You probably want to have either DNS access or /etc/hosts configured
# for your host and jump host name. In this example k8s-master-01 acts
# as the jump host to the DNS enabled k8s cluster

<<MSG
host k8s-git-repo
  User                  git
#  Port                  2222
# the name I have the k8s service. . .
#  Hostname             alternate-name
  IdentitiesOnly        yes
  TCPKeepAlive          yes
  IdentityFile          ~/.ssh/id_ed25519
# If connecting from non local work laptop for example . . .
  ProxyCommand       ssh -XC -A k8s-master-01 -W '%h:%p'
MSG

# ssh ${host} 'echo ${HOSTNAME}'

ssh ${host}<<INIT
mkdir ${repo}.git
cd ${repo}.git
git init --bare
INIT

git remote add ${repo} git@${host}:${repo}.git
git push --set-upstream ${repo} master

# alternatively 
# git remote add origin git@${host}:${repo}.git
# git push --set-upstream origin master
```

The formula in this assume that script/credentials has two environment
variables set: user + password. that file is sourced by script/functions

    ${KUBECTL} config --kubeconfig=${KUBECONFIG} set-credentials cluster-admin --username=${user} --password=${password}

Configure script/credentials with 600 permissions using standard shell
env variable syntax or source environment variables with the values
for the kubernetes kubectl access.

```
# script/credentials
user=name
password=password
```

chmod 600 script/credentials