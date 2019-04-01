---
title: Upstream Groups
weight: 33
description: Definition of Upstream Groups for Multi-Destinations
---

Gloo supports organizing upstreams in Groups. 

## Concept

An `UpstreamGroup`  is a top-level object, that, as the name says, allows you to logically group upstreams, giving you the ability to address them as a group in distinct VirtualServices. An upstream is the language we use to define something that will receive the traffic from Envoy, and it’s where you want your request to go ultimately.

Among other use cases, Upstream Groups can be very useful if you're running Canary Deployments or A/B tests. By having a top-level *object* that specifies your destinations, multiple virtual services can refer to the same top-level `UpstreamGroup`.
<img src="/img/inv2.png">
In the example above, when you change the destinations or the weights for the cartService `UpstreamGroup`, all users of the the `UpstreamGroup` will be impacted.
### Create your Upstream Group

```yaml
apiVersion: gloo.solo.io/v1
kind: UpstreamGroup
metadata:
  name: cartServiceUG
  namespace: gloo-system
spec:
  destinations:
  - destination:
    upstream:
        name: cartServiceV3
        namespace: gloo-system
    weight: 95
  - destination:
      upstream:
        name: cartServiceV4
        namespace: gloo-system
    weight: 5
```

As you can seem on the example Yaml above, an UpstreamGroup inherits the Multi-Action capability from Routes, meaning you can define weights, which, as said above, can be useful for Canary Deployments or A/B tests.

### Use your Upstream Group

Once you create your UpstreamGroup, they can be used inside the Route section of you Virtual service.

See below an example Yaml for a `virtualService` that uses the `upstreamGroup` defined above.

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: vs
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - '*'
    name: default
    routes:
    - matcher:
        prefix: /
      routeAction:
        upstreamGroup:
          name: cartServiceUG
          namespace: gloo-system
```

Together with Upstream Groups, there are now three types of actions that can be specified in a route:

- Single Action
- Multi Action
- Upstream Group

