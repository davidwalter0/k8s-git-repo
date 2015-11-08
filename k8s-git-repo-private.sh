#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
name=${dir##*/}
#name=private # ${dir##*/}
name=k8s-git-repo-private
yaml=${dir}/k8s-git-repo-private.yaml
# set -o errexit
set -o nounset
set -o pipefail

# For a secure tunnel to an kubernetes master you might do:
# kubemaster=10.14.140.19 ssh -f -nNT -L 8080:127.0.0.1:8080 core@${kubemaster}
export KUBE_HOST_OS_USER=centos
export KUBE_MASTER=k8s-dw-master-01
export KUBECTL=${dir}/bin/kubectl
export KUBECONFIG=${dir}/.cfg/.k8s-dw-master-01.cfg
. ${dir}/scripts/functions
rm ${yaml}
KUBECTL="${KUBECTL} --kubeconfig=${KUBECONFIG}"
username=dw
if [[ ! -e ${yaml} ]]; then
    cat > ${yaml} <<EOF
$(cat k8s-git-repo-rc+svc-private.yaml|                                                         \
  sed -r -e "s,namespace:.*k8s-git-repo.*,namespace: ${username}-private-k8s-git-repo,g"        \
         -e "s,app:.*k8s-git-repo.*,app: ${username}-private-k8s-git-repo,g"                    \
         -e "s,name:.*k8s-git-repo.*,name: ${username}-private-k8s-git-repo,g" )
---
apiVersion: v1
metadata:
  namespace: ${username}-private-k8s-git-repo
  name: ssh-key-secret
data:
  # id-rsa: $(base64 -w 0 ~/.ssh/id_rsa)
  # id-rsa.pub: $(base64 -w 0 ~/.ssh/id_rsa.pub)
  authorized-keys: $(base64 -w 0 ~/.ssh/id_rsa.pub)
kind: Secret

# local variables:
# comment-start: "# "
# mode: shell-script
# end:
EOF

fi
chmod 700 . ${yaml}
chmod 600 ${yaml}

if ! [[ ${KUBECTL-} ]]; then
    echo Fix the location of the kubectl command
    exit 1
fi

function start
{
    ${KUBECTL} create -f ${dir}/${name}.yaml
}

function stop
{
    ${KUBECTL} delete -f ${dir}/${name}.yaml
}

function status
{
    ${KUBECTL} get --output=wide node
    ${KUBECTL} get --all-namespaces --output=wide rc,pods,svc,ep
}

function usage
{
    cat <<EOF

${0##*/} [--start|--stop|--status]

Run a private git repo in kubernetes with k8s secret from ssh keys
injected at create time from the user's ~/.ssh/id_rsa{,.pub} files.

EOF
    exit 3
}

function main
{
    if (( $# )) ; then
        for arg in ${@}; do
            case ${arg} in
                --start)
                    start
                    ;;
                --stop)
                    stop
                    ;;
                --status)
                    status
                    ;;
                *)
                    usage
            esac
        done
    else
        usage
    fi
    exit
}

main ${@}

# local variables:
# comment-start: "# "
# mode: shell-script
# end:
