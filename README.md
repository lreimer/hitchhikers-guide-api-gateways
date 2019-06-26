# A Hitchhiker's Guide to Cloud Native API Gateways

This is the demo repository for my conference talk *Hitchhiker's Guide to Cloud Native API Gateways*.

Good APIs are the center piece of any successful digital product and cloud native application architecture. But for complex systems with many API consumers the proper management of these APIs is of utmost importance. The API gateway pattern is well established to handle and enforce concerns like routing, versioning, rate limiting, access control, diagnosability or service catalogs in a microservice architecture.

This repository will have a closer look at the cloud native API gateway ecosystem: Ambassador, Gloo, Kong, Tyc, KrakenD, et.al. But which one of these is the right one to use in your next project? Let's find out.

## Preparation

### Step 1: Create Kubernetes cluster

In this first step we are going to create a Kubernetes cluster on GCP. Issue the
following command fire up the infrastructure:
```
$ make prepare cluster
```

### Step 2: Install and initialize Helm

In this step we are going to install the Helm package manager so we can later easily
install the different API gateways.

```
$ make helm-install helm-init
```

## Envoy Proxy

### Simple Envoy Demo

Simple demo to proxy Google using envoy. Sample taken from Envoy docs.

```
$ make envoy-simple
$ docker-compose -f envoyproxy/simple/docker-compose.yml up
$ http get localhost:10000
$ open http://localhost:9901
```

### Envoy Front Proxy

This basically is a modified demo of the official sandbox repo from Envoy.

```
$ cd front-proxy
$ docker-compose up --build -d
$ docker-compose ps

$ http get localhost:8000/service/1
$ http get localhost:8000/service/2

$ docker-compose scale service1=3
$ docker-compose ps

$ http get localhost:8000/service/1
$ http get localhost:8000/service/1
$ http get localhost:8000/service/1

$ docker push lreimer/front-envoy:v1.0.0
$ docker push lreimer/service-envoy:v1.0.0
$ docker push lreimer/service-envoy:v2.0.0

$ kubectl apply -f front-envoy.yml
$ kubectl apply -f service1-envoy.yml
$ kubectl apply -f service2-envoy.yml

$ kubectl get service

$ http get http://<external-ip>:8000/service/1
$ http get http://<external-ip>:8000/service/2
$ http get http://<external-ip>:8000/service/1
$ http get http://<external-ip>:8000/service/1
```

## Ambassador

```
$ helm upgrade --install --wait my-ambassador stable/ambassador
$ kubectl get svc -w  --namespace default my-ambassador
$ kubectl apply -f https://getambassador.io/yaml/tour/tour.yaml
$ helm

$ kubectl create clusterrolebinding my-cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud info --format="value(config.account)")
$ kubectl apply -f https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml
```

## Gloo

```
$ brew install solo-io/tap/glooctl
$ curl -sL https://run.solo.io/gloo/install | sh

$ glooctl install gateway
$ #glooctl install gateway
$ glooctl uninstall --all

$ helm repo add gloo https://storage.googleapis.com/solo-public-helm
$ helm install gloo/gloo --name gloo-0-7-6 --namespace gloo-system
```

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.
