#!/bin/sh
#
# Check DU-LDC deployment / configuration are complete


####################################################
# Checks whether the machine config pool contains a 
#   specific module
# Globals:
#   VERBOSE - if defined, prints verbose status
# Arguments:
#   MC module name to check for presense
# Outputs:
#   None
#   Aborts the script if the module is not present
####################################################
function is_mcp_ready ()
{
    MODULE=\"$1\"
    QUERY="{.spec.configuration.source[?(@.name==$MODULE)].name}"
    # If module name is not present in the MCP, abort (not ready)
    if [ -z "$(oc get mcp worker-du-ldc -o jsonpath=$QUERY)" ]; then
        if [[ -n "${VERBOSE}" ]]; then
            echo "$1 not picked"
        fi
        exit 1
    fi
}

# Check machine config modules have been picked by MCO
is_mcp_ready "load-sctp-module-du-ldc"
is_mcp_ready "disable-chronyd-du-ldc"
is_mcp_ready "performance-perf-du-ldc"

# Check kernel patch daemonset has been scheduled on all applicable nodes
DS_MISS=$(oc get ds/rtos-du-ldc-ds -o \
    jsonpath='{.status.numberMisscheduled}')
if [[ ${DS_MISS} -gt 0 ]]; then
    if [[ -n "${VERBOSE}" ]]; then
        echo "Kernel patch daemonset is not updated yet"
    fi
    exit 1
fi

# Check MCP is updated
oc wait mcp/worker-du-ldc --for condition=updated --timeout 1s
