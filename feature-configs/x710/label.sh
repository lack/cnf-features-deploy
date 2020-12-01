node="node/cnfde6.ptp.lab.eng.bos.redhat.com"
oc label --overwrite $node node-role.kubernetes.io/worker-cnf=""
oc label --overwrite $node feature.node.kubernetes.io/network-sriov.capable="true"
