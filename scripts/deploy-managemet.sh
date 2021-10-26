#!/bin/bash -e

TKG_LAB_SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $TKG_LAB_SCRIPTS/set-env.sh

IAAS=$(yq e .iaas $PARAMS_YAML)

# Management Step 1
$TKG_LAB_SCRIPTS/01-prep-$IAAS-objects.sh
$TKG_LAB_SCRIPTS/02-deploy-$IAAS-mgmt-cluster.sh
$TKG_LAB_SCRIPTS/03-post-deploy-mgmt-cluster.sh
# Management Step 2
#if [ "$IAAS" != "aws" ];
#then
#  $TKG_LAB_SCRIPTS/tmc-register-mc.sh
#fi
# Management Step 3
$TKG_LAB_SCRIPTS/create-dns-zone.sh
$TKG_LAB_SCRIPTS/retrieve-lets-encrypt-ca-cert.sh
# Management Step 6
$TKG_LAB_SCRIPTS/generate-and-apply-contour-yaml.sh $(yq e .management-cluster.name $PARAMS_YAML)
$TKG_LAB_SCRIPTS/generate-and-apply-external-dns-yaml.sh $(yq e .management-cluster.name $PARAMS_YAML)
$TKG_LAB_SCRIPTS/generate-and-apply-cluster-issuer-yaml.sh $(yq e .management-cluster.name $PARAMS_YAML)
# Management Step 7
$TKG_LAB_SCRIPTS/update-pinniped-configuration.sh
# Management Step 8
$TKG_LAB_SCRIPTS/generate-and-apply-prometheus-yaml.sh \
  $(yq e .management-cluster.name $PARAMS_YAML) \
  $(yq e .management-cluster.prometheus-fqdn $PARAMS_YAML)
$TKG_LAB_SCRIPTS/generate-and-apply-grafana-yaml.sh \
  $(yq e .management-cluster.name $PARAMS_YAML) \
  $(yq e .management-cluster.grafana-fqdn $PARAMS_YAML)
