---
title: "Deploying the Bookinfo Example"
weight: 3
---

A number of tutorials make use of the [Istio Bookinfo](https://istio.io/docs/examples/bookinfo/) sample application. 
This guide explains how to deploy the Bookinfo Application with automatic sidecar injection enabled. 

**Prerequisites**: Istio or Linkerd must already be installed and running in your cluster. See [installing Istio](../install-istio) or [installing Linkerd](../install-linkerd) for instructions.

To deploy the bookinfo sample, first enable automatic sidecar injection on the default namespace (or any namespace of your choosing):

#### Istio Injection Label

```bash
kubectl label namespace default istio-injection=enabled
```

#### Linkerd Injection Annotation

```bash
kubectl annotate namespace default linkerd.io/inject=enabled
```

Next, create the bookinfo deployments and services:

```bash
kubectl apply -n default -f \
  https://raw.githubusercontent.com/istio/istio/1.0.6/samples/bookinfo/platform/kube/bookinfo.yaml
```

We should be up and running in a few minutes:

```bash
kubectl get pod -n default --watch

NAME                             READY     STATUS    RESTARTS   AGE
details-v1-6764bbc7f7-k4rhk      2/2       Running   0          27s
productpage-v1-54b8b9f55-sxxnw   2/2       Running   0          27s
ratings-v1-7bc85949-kh4f9        2/2       Running   0          27s
reviews-v1-fdbf674bb-z467l       2/2       Running   0          27s
reviews-v2-5bdc5877d6-gvgns      2/2       Running   0          27s
reviews-v3-dd846cc78-55wr5       2/2       Running   0          27s
```

We should see `2/2` containers are `READY`, since one of those containers is the sidecar injected by either Istio or Linkerd.
