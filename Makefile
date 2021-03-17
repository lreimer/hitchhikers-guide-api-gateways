NAME = api-gateways-guide
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
	# @$(K8S) apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
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

envoy-sources:
	@mkdir -p envoyproxy && rm -rf envoyproxy/envoy/
	@git clone --depth 1 https://github.com/envoyproxy/envoy envoyproxy/envoy

envoy-simple:
	@docker build -t envoy-simple:v1.0.0 envoyproxy/simple/
	@docker tag envoy-simple:v1.0.0 lreimer/envour-simple:v1.0.0
	@docker push lreimer/envour-simple:v1.0.0

krakend-simple:
	@docker build -t krakend-simple:v1.3.0 krakend/
	@docker tag krakend-simple:v1.3.0 lreimer/krakend-simple:v1.3.0
	@docker push lreimer/krakend-simple:v1.3.0

gloo-sources:
	@mkdir -p gloo && rm -rf gloo/solo-docs/
	@git clone --depth 1 https://github.com/solo-io/solo-docs gloo/solo-docs

ambassador-install:
	@$(K8S) apply -f ambassador/ambassador-rbac.yaml
	@$(K8S) apply -f ambassador/ambassador-service.yaml
	@$(K8S) apply -f ambassador/tour.yaml
	@$(K8S) get service ambassador

ambassador-delete:
	@$(K8S) delete -f ambassador/tour.yaml --ignore-not-found=true
	@$(K8S) delete -f ambassador/ratelimit.yaml --ignore-not-found=true
	@$(K8S) delete -f ambassador/ambassador-service.yaml --ignore-not-found=true
	@$(K8S) delete -f ambassador/ambassador-rbac.yaml --ignore-not-found=true

gloo-install:
	@glooctl install gateway
	@$(K8S) get pods --namespace gloo-system
	@$(K8S) get service gateway-proxy-v2 --namespace gloo-system

gloo-uninstall:
	@$(K8S) delete -f https://raw.githubusercontent.com/sololabs/demos2/master/resources/petstore.yaml --ignore-not-found=true
	@glooctl uninstall

destroy:
	@$(GCP) container clusters delete $(NAME) --async --quiet
