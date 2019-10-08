---
title: Filter Order
weight: 110
description: Details on how Gloo orders Envoy filters.
---

## Introduction

Gloo exposes and manages several Envoy filters.
For certain filters, relative order is irrelevant.
For others, filter order is critical to ensuring proper behavior.
This document show the order of filters as used in Open Source Gloo and Enterprise Gloo.

## Summary

Gloo orders Envoy's filters in the following order:

- Fault Injection [`FaultStage`, 0, "envoy.fault"]
- CORS [`CorsStage`, 0, "envoy.cors"]
- WAF (Enterprise) [`WafStage`, 0]
- ExtAuth - Sanitize (Enterprise) [`AuthNStage`, -1, "io.solo.filters.http.sanitize"]
- ExtAuth - AuthZ (Enterprise) [`AuthNStage`, 0, "envoy.ext_authz"] ???
- JWT (Enterprise) [`AuthNStage`, 0]
- RBAC (Enterprise) [`AuthZStage`, 0]
- gRPC Web [`AuthZStage`, 1]
- Transformation [`AuthZStage`, 1, "io.solo.transformation"]
- Health Check [`AuthZStage`, 1]
- Translator  [`AuthZStage`, 1]
- Rate Limit (Enterprise) [`RateLimitStage`, 0]
- gRPC [`OutAuthStage`, -1]
- AWS Lambda [`OutAuthStage`, -1]
- Router [always last, envoy.router]




## Filter order management details

Gloo uses an extensible [1] filter ordering system to manage the order of Envoy filters.
Filters are placed relative to a list of `WellKnownFilterStage`.

The list of `WellKnownFilterStage`s includes:
```go
FaultStage     // Fault injection // First Filter Stage
CorsStage      // Cors stage
WafStage       // Web application firewall stage
AuthNStage     // Authentication stage
AuthZStage     // Authorization stage
RateLimitStage // Rate limiting stage
AcceptedStage  // Request passed all the checks and will be forwarded upstream
OutAuthStage   // Add auth for the upstream (i.e. aws λ)
RouteStage     // Request is going to upstream // Last Filter Stage
```

The placement of each particular filter is defined relative to a given `WellKnownFilterStage`, by a certain weight.
```go
RelativeToStage(wellKnown WellKnownFilterStage, weight int)
```

Ordering is evaluated by first comparing the `WellKnownFilterStage`, then the `weight`, and, as a tie breaker, the filter's name.
To give a few examples:

- All filters defined relative to the `CorsStage` will come after all filters defined relative to the `FaultStage` and before all filters defined relative to the `WafStage`.
- If two filters are defined relative to the same stage, the filter with the lower weight will come first.
- If two filters are defined relative to the same stage and have the same weight, the filter with an alpha-numerically lesser name will come first.

#### Footnotes

1. At the moment, Gloo must be recompiled to alter filter ordering.
In the future, this capability may be exposed as a configuration option.
