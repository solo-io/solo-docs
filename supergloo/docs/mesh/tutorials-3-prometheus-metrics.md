---
title: "Tutorial: Configuring Prometheus to Collect Istio Metrics"
weight: 5
---

### Summary

In this tutorial we'll take a look at how to configure [the Prometheus monitoring system](https://prometheus.io/) to scrape our meshes for metrics using SuperGloo.

Monitoring the traffic being sent between a system of microservices is one of the primary features provided by service meshes. Service meshes make it easy to collect
 metrics from a large, distributed system in a centralized metrics store such as Prometheus. Typically, when installing a mesh, the mesh and metrics store must be manually configured in order to produce readable metrics.
 
SuperGloo provides features to automatically propagate metrics from a managed mesh with one or more instances of a metrics store. 

Let's dive right in.

### Tutorial

First, ensure you've:

- [installed SuperGloo](../../installation)
- [installed Istio using supergloo](../install)
- [Deployed the Bookinfo sample app](../bookinfo)

Next, we'll need an instance of Prometheus running in our cluster. If you've already got Prometheus installed, you can skip this step.

> Note: For SuperGloo to configure Prometheus correctly, it requires that the Prometheus server is configured with a 
> [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/), and that the
> key for the Prometheus configuration file is named `prometheus.yml` 

To install a simple Prometheus instance for the purpose of this tutorial, run the following:

```yaml
kubectl create ns prometheus-test
kubectl apply -n prometheus-test -f \
  https://raw.githubusercontent.com/solo-io/solo-docs/master/supergloo/exampeles/prometheus/prometheus-demo.yaml
```

> Note: We can watch the pods get created for Prometheus with `kubectl get pod -n prometheus-test -w`
 
Let's take a look at the configmap that was created by this install for us:

```bash
kubectl get configmap -n prometheus-test

NAME                DATA      AGE
prometheus-server   3         5s
```

We'll need to pass the name `prometheus-test.prometheus-server` to SuperGloo as a configuration option for our mesh.

Run the following command to connect your Istio mesh to the Prometheus instance we just installed:

```bash
supergloo set mesh stats \
  --target-mesh supergloo-system.istio \
  --prometheus-configmap prometheus-test.prometheus-server
```

We can see the configuration that this applied to our Mesh CRD by running:

{{< highlight yaml "hl_lines=16-19" >}}
kubectl get mesh -n supergloo-system istio -o yaml

apiVersion: supergloo.solo.io/v1
kind: Mesh
metadata:
  creationTimestamp: 2019-03-28T18:44:46Z
  generation: 1
  name: istio
  namespace: supergloo-system
  resourceVersion: "178284"
  selfLink: /apis/supergloo.solo.io/v1/namespaces/supergloo-system/meshes/istio
  uid: 8f57f47e-5189-11e9-9c12-b0cb59a58200
spec:
  istio:
    installationNamespace: istio-system
  monitoringConfig:
    prometheusConfigmaps:
    - name: prometheus-server
      namespace: prometheus-test
  mtlsConfig:
    mtlsEnabled: true
status:
  reported_by: istio-config-reporter
  state: 1
{{< /highlight >}}

Notice how the `monitoringConfig` now contains an entry for our `prometheus-server` configmap.

Let's take a look at the metrics that our Prometheus instance should have started collecting for our mesh.

Open up a port-forward to reach the Prometheus UI from our local machine:

```yaml
kubectl port-forward -n prometheus-test deployment/prometheus-server 9090
```

Now direct your browser to http://localhost:9090/

You should see the Prometheus Graph page show up:

![Prometheus Landing Page](../../img/prometheus-landing-page.png "Prometheus Landing Page")

Let's enter a query to see some stats from Istio:

![Prometheus Initial Query](../../img/prometheus-initial-query.png "Prometheus Initial Query")

Let's try creating some metrics by sending traffic to some of our Bookinfo pods. Open the port-forward to 
reach the productpage:

```bash
kubectl port-forward -n default deployment/productpage-v1 9080
```

Open your browser to http://localhost:9080/productpage. Refresh the page a few times - 
this will cause the product page to send requests to the reviews and ratings services.

Now let's check back in Prometheus and refresh our graph:

![Prometheus Updated Query](../../img/prometheus-updated-query.png "Prometheus Updated Query")

Great! We've just seen how SuperGloo makes it easier to connect an existing Prometheus installation
to a managed Mesh with a minimal amount of work. 