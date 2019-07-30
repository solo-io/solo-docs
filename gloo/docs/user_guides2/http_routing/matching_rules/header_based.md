---
title: Header Based
weight: 2
---

When configuring the matcher on a route, you want to specify one or more 
[Header Matcher]({{% ref "/v1/github.com/solo-io/gloo/projects/gloo/api/v1/proxy.proto.sk#headermatcher" %}}) to require headers 
with matching values be present on the request. Each header matcher has three attributes:

* `name` - the name of the request header. Note: Gloo/Envoy use HTTP/2 so if you want to match against HTTP/1 `Host`,
use `:authority` (HTTP/2) as the name instead.
* `regex` - boolean (true|false) defaults to `false`. Indicates how to interpret the `value` attribute:
  * `false` (default) - treat `value` field as an [Envoy exact_match](https://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/route/route.proto#envoy-api-field-route-headermatcher-exact-match)
  * `true` - treat `value` field as a regular expression as defined by [Envoy regex_match](https://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/route/route.proto#envoy-api-field-route-headermatcher-regex-match)
* `value`
  * If no value is specified, then the presence of the header in the request with any value will match
([Envoy present_match](https://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/route/route.proto#envoy-api-field-route-headermatcher-present-match))
  * If present, then field value interpreted based on the value of `regex` field

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

Now let's create a virtual service with a header match: 

{{< highlight yaml "hl_lines=12-15" >}}
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: test-header
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    routes:
    - matcher:
        headers:
        - name: header1
          value: value1
        - name: header2
        - name: header3
          regex: true
          value: "[a-z]{1}"
        prefix: /
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
{{< /highlight >}}

TODO
To create the above route using `glooctl`, you can do the following. Multiple `--headers` can be specified. The CLI will
try to inspect the provided value to guess if its a regular expression (or not), and set the `regex` field accordingly.

```shell
glooctl add route \
    --name default \
    --header "foo=bar" \
    --path-prefix /hello \
    --dest-name default-hello-8080
```

To test you can use `glooctl proxy url` to get the Gloo gateway base URL, and then add the path.


Test: 
```shell
curl -v -H "Host: foo" -H "header1: value1" -H "header2: value2" -H "header3: v"  $GATEWAY_URL/posts
```
Works

Incorrect value for header1: 

```shell
curl -v -H "Host: foo" -H "header1: othervalue" -H "header2: value2" -H "header3: v"  $GATEWAY_URL/posts
```
404

Other value for header2:
```shell
curl -v -H "Host: foo" -H "header1: value1" -H "header2: othervalue" -H "header3: v"  $GATEWAY_URL/posts
```
Works

Incorrect value for header3:
```shell
curl -v -H "Host: foo" -H "header1: value1" -H "header2: value2" -H "header3: value3"  $GATEWAY_URL/posts
```
404

## Cleanup

Delete vs and upstream


