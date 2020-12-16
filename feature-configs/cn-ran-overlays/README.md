# __Cloud-native RAN profile__

# Introduction
This folder contains an example configurations for 5G radio access network (RAN).
The 5G RAN in the broader context is shown below:

*Source: 3GPP TS 23.501-g60*
<img src="images/ran-3gpp.png">

RAN external interfaces (N2 and N3) carry control plane and user plane data respectively. They compose RAN backhaul networks. RAN backhaul may also aggregate one or more management networks, while the separation between all the networks is often realized through VLAN tagging.
N1 interface is transparent to RAN (encapsulated in N2).

Radio access network is divided to Centralized units (CU), distributed units (DU) and Radio units (RU). Centralized units are split to control plane and user plane functions (CU-CP and CU-UP respectively).
RAN entities and internal interfaces from the telecommunications standard perspective are shown below:

<img src="images/ran.png">

From the high level blocks composing RAN (CU, DU, RU), only CU and DU can be virtualized and implemented as cloud-native functions.
CU / DU split is driven by real-time computing and networking requirements. A DU can be seen as a real-time part of a telecommunication baseband unit. One distributed unit may aggregate several cells. A CU can be seen as a non-realtime part of a baseband unit, aggregating traffic and controlling one or more distributed units.

A cell in the context of a DU can be seen as a real-time application performing intensive digital signal processing, data transfer and algorithmic tasks. Cells are often using hardware acceleration (FPGA, GPU, eASIC) for DSP processing offload. There are also software-only implementations (FlexRAN), based on AVX-512 instructions. 
Running cell application on COTS hardware requires following features to be enabled:

- Real-time kernel
- CPU isolation
- NUMA awareness
- HUGEPAGES memory management
- Precision timing synchronization using PTP
- AVX-512 instruction set (for Flexran and / or FPGA implementation)
- Additional features depending on the RAN operator requirements

Accessing hardware acceleration devices and high throughput network interface cards by virtualized software applications requires use of SR-IOV and/or Passthrough PCI device virtualization.
In addition to the compute and acceleration requirements, RAN nodes operate on multiple internal and external networks.

# Overview

The current directory contains declarative manifests for RAN integration features deployment, namely:
- SCTP MachineConfig patch
- Performance addon operator and CU / DU performance profiles
- PTP operator and slave profile
- SR-IOV operator and associated configurations

## The deployment model

The RAN deployment modeled here is shown below:
<img src="images/sites.png">

The OCP cluster aggregates two sites. There is a local data center (`site-ldc`), that hosts a pool of CU-UP nodes, one CU-CP node and a pool of DU nodes deployed on a dual-socket servers.
In addition, there is a FEC site (`site-fec`) containing one DU remote worker node implemented on a single-socket server.
This means that the cluster we are deploying will have at least the following worker node types:

- __worker-du-fec__ - A DU worker node implemented on a single-socket server, with performance tuning, ptp synchronization, SCTP patch and at least three SR-IOV networks (in addition to the Openshift cluster network, BMC and other management networks, that are out of this model' scope):
    - The fronthaul network, connecting the DU to the RU(s)
    - The midhaul user plane network, connecting the DU to CU-UP and carrying the user traffic
    - The midhaul control plane network, connecting the DU to CU-CP and carrying the F1AP protocol [3GPP TS 38.473](https://www.3gpp.org/ftp//Specs/archive/38_series/38.473/)
  DU networks are described [here](#du_nw)
- __worker-du-ldc__ - A DU worker node implemented on a dual-socket server. Contains the same modifications as worker-du-fec, with the nunber of SR-IOV networks raising to 6 (three per NUMA node). 
- __worker-cu-up__ - A CU-UP node implemented on a dual-socket server. CU-UP will have different pereformance optimizations than a DU, and will use NTP for time synchronization. CU-UP will require two SR-IOV networks per NUMA node, one for the midhaul connection to distributed units, and another - for the backhaul connection to the 5G core. Total four SR-IOV networks  per node. CU-UP networks are described [here](#cu_up_nw)
- __worker-cu-cp__ - A CU-CP node implemented on a dual-socket server. Has similar requirements to CU-UP (not implemented in the current version of the RAN profile.)






### <a name="cu_up_nw"></a>CU-UP networks

<img src="images/cu-up.png">

### <a name="du_nw"></a>DU networks
<img src="images/du-ldc.png">


## The manifest structure

The manifest structure follows the deployment model described above. The [basic-profile](./basic-profile) folder contalins the performance and PTP profiles and references the operator deployments in the project' [`deploy`](../feature-configs/deploy) folder.

The [`cu-up`](./cu-up),  [`du-fec`](du-fec) and [`du-ldc`](du-ldc) folders contain node type specific customizations. The number of node type specific folders can be increased to fit the particular deployment. 

### Scaling

This structure can be scaled to accommodate more worker node types, however the assumption is that all the nodes performing the same function in a particular cluster will be identical in terms of the hardware used and the VLAN tags. If this is not the case, SR-IOV network node selectors may be separated from PTP, PAO and machineconfig patches node selectors.


# Prerequisites


## 1. Create machine config pools for the RAN worker nodes. 

### DU-FEC worker example:

```bash

cat <<EOF | oc apply -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: worker-du-fec
  labels:
    machineconfiguration.openshift.io/role: worker-du-fec
spec:
  machineConfigSelector:
    matchExpressions:
      - {
          key: machineconfiguration.openshift.io/role,
          operator: In,
          values: [worker-du-fec, worker],
        }
  paused: false
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/worker-du-fec: ""
---
EOF
```

### Other node types
For DU-LDC, CU-UP and other types you might need, create as many additional machine config pools as needed for your deployment

## 2. Label the nodes
Include the designated worker nodes in the above machine config pools by labelling them as described below. 

### DU FEC nodes

```bash
oc label --overwrite node/{your node name} node-role.kubernetes.io/worker-du-fec=""
```

### DU LDC nodes

```bash
oc label --overwrite node/{your node name} node-role.kubernetes.io/worker-du-ldc=""
```

### CU-UP nodes
```bash
oc label --overwrite node/{your node name} node-role.kubernetes.io/worker-cu-up=""
```

## 3. Choose the operators image stream

By default the operators will be installed from the upstream branch.
This can be changed in [`basic-profile/kustomization.yaml`](basic-profile/kustomization.yaml) to match your OCP version.


## 4. Update the manifests for your specific hardware 
Performance profiles, SR-IOV network policies and PTP profile must take the specific hardware details into account.


### Performance profile
In the `<node type>/customizations/performance` folders, update the `performance.yaml` to reflect the amount of CPU cores available on the correspondent nodes and your application requirements with respect to the kernel type and arguments.

### SR-IOV network node policies
In the `<node type>/networks` folders, update the SR-IOV network node policies to reflect the manufacturer details and physical NIC port names on your hardware.


#### SR-IOV configuration notes
SriovNetworkNodePolicy object must be configured differently for different NIC models and placements. 

| Manufacturer | deviceType | isRdma |
| --- | --- | --- |
| Intel | __vfio-pci__ or __netdevice__ | __false__ |
| Mellanox | __netdevice__ | __true__ |


In addition, when configuring the `nicSelector`, `pfNames` value must match the intended interface name on the specific host.

If there is a mixed cluster where some of the nodes are deployed with Intel NICs and some with Mellanox, several SR-IOV configurations can be created with the same `resourceName`. The device plugin will discover only the available ones and will put the capacity on the node accordingly.

#### __How to find your NIC information__
SSH to your worker node:
```bash
ssh core@<your worker node>
```


##### __Find relation between interface names and PCI addresses__
```bash
[core@node ~]$ grep PCI_SLOT_NAME /sys/class/net/*/device/uevent
/sys/class/net/eno1/device/uevent:PCI_SLOT_NAME=0000:19:00.0
/sys/class/net/eno2/device/uevent:PCI_SLOT_NAME=0000:19:00.1
/sys/class/net/ens1f0/device/uevent:PCI_SLOT_NAME=0000:3b:00.0
/sys/class/net/ens1f1/device/uevent:PCI_SLOT_NAME=0000:3b:00.1
/sys/class/net/ens3f0/device/uevent:PCI_SLOT_NAME=0000:d8:00.0
/sys/class/net/ens3f1/device/uevent:PCI_SLOT_NAME=0000:d8:00.1

```


##### __Find NIC NUMA nodes__

```bash
[core@node ~]$ cat /sys/class/net/*/device/numa_node
0
0
0
0
1
1

```


##### __Find relation between PCI addresses and NIC manufacturers__
```bash
[core@node ~]$ lspci |grep Ether
19:00.0 Ethernet controller: Mellanox Technologies MT27710 Family [ConnectX-4 Lx]
19:00.1 Ethernet controller: Mellanox Technologies MT27710 Family [ConnectX-4 Lx]
3b:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
3b:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
d8:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
d8:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)

```


### PTP NIC port selector in PTP profile
Update the PTP slave port selector in the `<node type>/customizations/ptp` folders to match your designated PTP port name:

```yml
# Replace the value below to match your hardware
- op: replace
  path: /spec/profile/0/interface
  value: "ens5f0"
```




# Deployment

The profile is built in layers with __kustomize__.
To get the Kustomize output for a specific node type, run 
```bash
./kustomize build <path to the node specific folder>
```
It can be applied manually or with the toolset of your choice (E.g. ArgoCD)

This project contains makefile based tooling, that can be used as follows (from the project root):

  `FEATURES_ENVIRONMENT=cn-ran-overlays FEATURES="du-ldc cu-up" make feature-deploy`

This will deploy du-ldc and cu-up (any number of configurations can be set in the `FEATURES`)

