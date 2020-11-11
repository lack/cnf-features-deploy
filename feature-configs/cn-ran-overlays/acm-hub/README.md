# acm-hub

ACM hub installation resources

## Overview

This directory contains resources for ACM hub installation.

## Deployment

1. [Optional] Define your pull secret file by running
```bash
  export ACM_PULL_SECRET_FILE=<path-to-your-file>
```
If not defined, a default pull secret file is assumed to be at `/root/openshift_pull.json` 

2. Run 
```bash
  ./setup_acm_hub.sh
```
This will prepare following:
- Create namespace `open-cluster-management`
- Create a secret in the above namespace from a pull secret file. 

3. Run 
  
```bash
  
  FEATURES_ENVIRONMENT=cn-ran-overlays FEATURES=acm-hub make feature-deploy
```

4. Wait for the iterations to complete

5. Wait one minute and run 
```bash
oc project open-cluster-management
oc get routes -n open-cluster-management
```
to get a route to the ACM console. 

6. Login to the console with your cluster' kubeadmin credentials. (It can take ~2-3 minutes until the console can be accessed)

For official instructions on ACM hub installation, please refer to https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.1/html/install/installing 
