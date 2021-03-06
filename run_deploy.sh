#!/usr/bin/env bash

if [[ $CIRCLE_BRANCH == "staging" ]]; then
  RANCHER_CLUSTER=$RANCHER_CLUSTER_STAGING
fi;

# rancher login
echo -e "${yellow}\nRancher Login${noc}"
rancher login $RANCHER_API --token $RANCHER_TOKEN --context $RANCHER_CLUSTER

# Set image to deployments files
sed -i -e "s/%{{BRANCH}}/$CIRCLE_BRANCH-$CIRCLE_BUILD_NUM/g" .production/deployments/deployment.yaml

# kubernetes apply default deployment
echo -e "${blue}\nDefault Deploy${noc}"
rancher kubectl apply \
  -f .production/deployments/deployment.yaml \
  -f .production/services/web-service.yaml \
  -f .production/ingress/$CIRCLE_BRANCH.yaml \
  --namespace=api-$CIRCLE_BRANCH

echo -e "${blue}\nDefault Deployment Success${noc}"

# Revert files state
sed -i -e "s/$CIRCLE_BRANCH-$CIRCLE_BUILD_NUM/%{{BRANCH}}/g" .production/deployments/deployment.yaml
