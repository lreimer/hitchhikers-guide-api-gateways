NAME = hitchhikers-guide-api-gateways
VERSION = 1.0.0
GCP = gcloud
ZONE = europe-west1-b
K8S = kubectl

.PHONY: info

info:
	@echo "A Hitchhiker's Guide to Cloud Native API Gateways"

prepare:
	@$(GCP) config set compute/zone $(ZONE)
	@$(GCP) config set container/use_client_certificate False

cluster:
	@echo "Create GKE Cluster"
	# --[no-]enable-basic-auth --[no-]issue-client-certificate

	@$(GCP) container clusters create $(NAME) --num-nodes=5 --enable-autoscaling --min-nodes=5 --max-nodes=10
	@$(K8S) create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@$(K8S) create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
	@$(K8S) cluster-info

helm-install:
	@echo "Install Helm"
	@curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

helm-init:
	@echo "Initialize Helm"

	# add a service account within a namespace to segregate tiller
	@$(K8S) --namespace kube-system create sa tiller

	# create a cluster role binding for tiller
	@$(K8S) create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

	@helm init --service-account tiller
	@helm repo update

	# verify that helm is installed in the cluster
	@$(K8S) get deploy,svc tiller-deploy -n kube-system

gcloud-login:
	@$(GCP) auth application-default login

access-token:
	@$(GCP) config config-helper --format=json | jq .credential.access_token

dashboard:
	@$(K8S) proxy & 2>&1
	@sleep 3
	@$(GCP) config config-helper --format=json | jq .credential.access_token
	@open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

destroy:
	@$(GCP) container clusters delete $(NAME) --async --quiet
