#!/bin/sh

READY=0
function is_mcp_ready ()
{
    # no output means that the new machine config wasn't picked by MCO yet
    if [ -z "$(oc get mcp worker-du-ldc -o jsonpath='{.spec.configuration.source[?(@.name=="$1")].name}')" ]; then
        if [[ -n "${VERBOSE}" ]]; then
            echo "$1 not picked"
        fi
    exit 1
fi

is_mcp_ready("load-sctp-module")

# }
# # SCTP MC patch
# if [ -z "$(oc get mcp worker-du-ldc -o jsonpath='{.spec.configuration.source[?(@.name=="load-sctp-module")].name}')" ]; then
#     exit 1
# fi

# # Disable chronyd patch
# if [ -z "$(oc get mcp worker-du-ldc -o jsonpath='{.spec.configuration.source[?(@.name=="disable-chronyd-du-ldc")].name}')" ]; then
#     exit 1
# fi

# # Performance profile
# if [ -z "$(oc get mcp worker-du-ldc -o jsonpath='{.spec.configuration.source[?(@.name=="performance-perf-du-ldc")].name}')" ]; then
#     exit 1
# fi


# oc wait mcp/worker-cnf --for condition=updated --timeout 1s
