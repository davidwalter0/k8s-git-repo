#!/bin/bash
dir=$(dirname $(readlink -f ${0}))
# set -o errexit
set -o nounset
set -o pipefail

# For a secure tunnel to an kubernetes master you might do:
# kubemaster=10.14.140.19 ssh -f -nNT -L 8080:127.0.0.1:8080 core@${kubemaster}
export KUBE_HOST_OS_USER=centos
export KUBE_MASTER=k8s-dw-master-01
export KUBECTL=${dir}/bin/kubectl
export KUBECONFIG=${dir}/.cfg/.k8s-dw-master-01.cfg
. scripts/functions

KUBECTL="${KUBECTL} --kubeconfig=${KUBECONFIG}"

if ! [[ ${KUBECTL-} ]]; then
    echo Fix the location of the kubectl command
    exit 1
fi

function start-git
{
    ${KUBECTL} create -f ${dir}/k8s-git-repo.yaml 
}

function stop-git
{
    ${KUBECTL} delete -f ${dir}/k8s-git-repo.yaml
}

function status-git
{
    ${KUBECTL} get --output=wide node
    ${KUBECTL} get --all-namespaces --output=wide rc,pods,svc,ep
}

function main
{
    for arg in ${@}; do
        case ${arg} in
            --start-git)
                start-git
                ;;
            --stop-git)
                stop-git
                ;;
            --status-git|--status*)
                status-git
                ;;
        esac
    done
}

main ${@}
