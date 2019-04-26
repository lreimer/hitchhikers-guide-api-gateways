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

## Maintainer

M.-Leander Reimer (@lreimer), <mario-leander.reimer@qaware.de>

## License

This software is provided under the MIT open source license, read the `LICENSE`
file for details.
