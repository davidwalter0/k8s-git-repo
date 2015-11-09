#!/bin/bash
debug=0
dir=$(dirname $(readlink -f ${0}))
# set -o errexit
set -o nounset
set -o pipefail

# This script is using credentials sourced from .private/.{master}.cfg
# generated by script/functions on first call which prompts for the
# cluster user and password and stores the credential in the config
# file.

. ${dir}/.cfg/functions

function make-yaml
{
  sed -r -e "s,namespace:.*k8s-git-repo.*,namespace: ${prefix}-k8s-git-repo,g"          \
         -e "s,app:.*k8s-git-repo.*,app: ${prefix}-k8s-git-repo,g"                      \
         -e "s,name:.*k8s-git-repo.*,name: ${prefix}-k8s-git-repo,g"                    \
         -e "s,authorized-keys:.*,authorized-keys: $(base64 -w 0 ~/.ssh/id_${ssh_key_type}.pub),g"  \
         ${inyaml}
}

main ${@}

# local variables:
# comment-start: "# "
# mode: shell-script
# end:
