#!/bin/bash

GOPATH=${GOPATH:-${HOME}/go}
MCMAKER=${GOPATH}/bin/mcmaker

${MCMAKER} -stdout -name 04-accelerated-container-startup -mcp master \
	file -source accelerated-container-startup.sh -path /usr/local/bin/accelerated-container-startup.sh -mode 0755 \
	unit -source accelerated-container-startup.service \
        unit -source accelerated-container-shutdown.service
