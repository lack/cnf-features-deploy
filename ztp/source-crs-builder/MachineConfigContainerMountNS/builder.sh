#!/bin/bash

GOPATH=${GOPATH:-${HOME}/go}
MCMAKER=${GOPATH}/bin/mcmaker

${MCMAKER} -name mc-container-mount-namespace -mcp master -stdout \
        file -source extractExecStart -path /usr/local/bin/extractExecStart -mode 0755 \
        file -source nsenterCmns -path /usr/local/bin/nsenterCmns -mode 0755 \
        unit -source container-mount-namespace.service \
        dropin -source 20-container-mount-namespace.conf -for kubelet.service \
        dropin -source 20-container-mount-namespace.conf -for crio.service
