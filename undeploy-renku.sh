#!/bin/bash

TILLER_NAMESPACE=${TILLER_NAMESPACE:-tiller}
ACME_NAMESPACE=${ACME_NAMESPACE:-acme}
RENKU_NAMESPACE=${RENKU_NAMESPACE:-renku}

# tiller
oc delete project ${TILLER_NAMESPACE}

# certs
oc delete project ${ACME_NAMESPACE}

# renku
oc delete project ${RENKU_NAMESPACE}

echo "give Kubernetes couple of seconds to settle out"