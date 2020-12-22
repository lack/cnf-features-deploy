#!/bin/sh
#
# Check DU-LDC deployment / configuration are complete

CONFIGURATION="du-ldc"
ROLE="worker-$CONFIGURATION"

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
    if [ -z "$(oc get mcp $ROLE -o jsonpath=$QUERY)" ]; then
        abort "$1 not picked"
    fi
}


function abort ()
{
    if [[ -n "${VERBOSE}" ]]; then
            echo "$1"
    fi
    exit 1
}

# Check machine config modules have been picked by MCO
is_mcp_ready "load-sctp-module-$CONFIGURATION"
is_mcp_ready "disable-chronyd-$CONFIGURATION"
is_mcp_ready "performance-perf-$CONFIGURATION"

# Check kernel patch daemonset has been scheduled on all applicable nodes
DS_MISS=$(oc get ds/rtos-$CONFIGURATION-ds -o \
    jsonpath='{.status.numberMisscheduled}')
if [[ ${DS_MISS} -gt 0 ]]; then
    abort "Kernel patch daemonset is not updated yet"
fi

# Check hernel has been patched on all machines
LST_KERNELS=$(oc get no -l node-role.kubernetes.io/$ROLE="" -o json \
    |grep '"kernelVersion": ')
IFS=,
for value in $LST_KERNELS;
do
    if [[ -z $(echo $value |grep rt) ]]; then
       abort "Kernel has not been patched yet on all machines"
    fi
done

# Check MCP is updated
oc wait mcp/worker-du-ldc --for condition=updated --timeout 1s
