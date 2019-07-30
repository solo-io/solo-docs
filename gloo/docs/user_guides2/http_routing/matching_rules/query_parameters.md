---
title: Query Parameters
weight: 3
---

When configuring the matcher on a route, you want to specify one or more 
[Query Parameter Matcher]({{% ref "/v1/github.com/solo-io/gloo/projects/gloo/api/v1/proxy.proto.sk#queryparametermatcher" %}})
to require query parameters with matching values be present on the request. Each query parameter matcher has three attributes:

* `name` - the name of the query parameter
* `regex` - boolean (true|false) defaults to `false`. Indicates how to interpret the `value` attribute:
  * `false` (default) - will match if `value` exactly matches query parameter value
  * `true` - treat `value` field as a regular expression
* `value`
  * If no value is specified, then the presence of the query parameter in the request with any value will match
  * If present, the `value` field will be interpreted based on the value of `regex` field

## Setup

Let's create a simple upstream for testing: 

`glooctl create upstream static --static-hosts jsonplaceholder.typicode.com:80 --name json-upstream`

Or create the CRD directly using `kubectl apply`:
```yaml
apiVersion: gloo.solo.io/v1
kind: Upstream
metadata:
  name: json-upstream
  namespace: gloo-system
spec:
  upstreamSpec:
    static:
      hosts:
      - addr: jsonplaceholder.typicode.com
        port: 80
```

Now let's create a virtual service with a query parameter match: 

{{< highlight yaml "hl_lines=12-15" >}}
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: test-query-parameter
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    routes:
    - matcher:
        queryParameters:
        - name: param1
          value: value1
        - name: param2
        - name: param3
          regex: true
          value: "[a-z]{1}"
        prefix: /
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
{{< /highlight >}}


Test: 
```shell
curl -v -H "Host: foo" "$GATEWAY_URL/posts?param1=value1&param2=value2&param3=v"
```
Works
Must use quotes on the URL!

Incorrect value for query param 1: 
```shell
curl -v -H "Host: foo" "$GATEWAY_URL/posts?param1=othervalue&param2=value2&param3=v"
```
404

Other value for header2:
```shell
curl -v -H "Host: foo" "$GATEWAY_URL/posts?param1=value1&param2=othervalue&param3=v"
```
Works

Incorrect value for header3:
```shell
curl -v -H "Host: foo" "$GATEWAY_URL/posts?param1=value1&param2=value2&param3=vv"
```
404

## Cleanup

Delete vs and upstream


