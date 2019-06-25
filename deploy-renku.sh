#!/bin/bash
OC_CLUSTER_ID="brno-8647"
HELM_VERSION=${HELM_VERSION:-"v2.11.0"}
export TILLER_NAMESPACE=${TILLER_NAMESPACE:-"tiller"}
ACME_NAMESPACE=${ACME_NAMESPACE:-"acme"}
RENKU_NAMESPACE=${RENKU_NAMESPACE:-"renku"}
HOST=${HOST:-"renku.apps.cluster-$OC_CLUSTER_ID.$OC_CLUSTER_ID.openshiftworkshop.com"}


#rbac openshift
# oc replace --filename ./htpass-secret.yaml

# tiller
oc new-project ${TILLER_NAMESPACE} &> /dev/null && echo "namespace ${TILLER_NAMESPACE} created"
oc process -f https://github.com/openshift/origin/raw/master/examples/helm/tiller-template.yaml -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" -p HELM_VERSION=${HELM_VERSION} | oc apply -n ${TILLER_NAMESPACE} -f -
oc rollout status deployment tiller
helm version
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:tiller:tiller

# certs
oc new-project ${ACME_NAMESPACE} &> /dev/null && echo "namespace ${ACME_NAMESPACE} created"
oc apply -f acme/ -n ${ACME_NAMESPACE}
oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme -n ${ACME_NAMESPACE}

# renku
oc new-project ${RENKU_NAMESPACE} &> /dev/null && echo "namespace ${RENKU_NAMESPACE} created"
oc adm policy add-scc-to-user anyuid -z default -z hub

# process the value file
sed "s;#@renku@#;$HOST;g" values-template.yaml > values.yaml
helm upgrade --install renku --namespace ${RENKU_NAMESPACE} -f values.yaml renku-0.3.2.tgz
rm values.yaml || true

# nginx
oc new-app nginx:1.12~https://github.com/jkremser/renku-openshift.git --context-dir=nginx --name=nginx
sleep 60 # meh
sed "s;#@renku@#;$HOST;g" nginx-route-template.yaml > nginx-route.yaml
oc apply -f ./nginx-route.yaml
rm nginx-route.yaml || true
oc patch route renku -p '{"metadata":{"annotations":{"kubernetes.io/tls-acme":"true"}}}'

# readiness probe for gw to true