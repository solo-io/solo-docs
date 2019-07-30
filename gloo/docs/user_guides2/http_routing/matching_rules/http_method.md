---
title: HTTP Method
weight: 4
---

You can also create route rules based on the request HTTP method, e.g. GET, POST, DELETE, etc. You can specify one or
more HTTP Methods to match against, and if any one of those method verbs is present, the request will match, that is
Gloo will conditional OR the match for HTTP Method. Note: since Gloo/Envoy is based on HTTP/2, this gets translated
into a header value match against the HTTP/2 `:method` header, which [by spec](https://http2.github.io/http2-spec/#HttpRequest)
includes all of the HTTP/1 verbs.

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

Now let's create a virtual service with an http method match: 

{{< highlight yaml "hl_lines=12-15" >}}
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: test-method
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    routes:
    - matcher:
        methods:
        - POST
        prefix: /
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
{{< /highlight >}}

Let's POST to that route and make sure it works:

```shell
curl -H "Host: foo" -XPOST $GATEWAY_URL/posts
```

returns

```
{
  "id": 101
}
```

Let's update the route to accept GET:

{{< highlight yaml "hl_lines=12-15" >}}
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: test-method
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    routes:
    - matcher:
        methods:
        - GET
        prefix: /
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
{{< /highlight >}}

Now this returns a 404:

```shell
curl -H "Host: foo" -XPOST $GATEWAY_URL/posts
```

But this succeeds:

```shell
curl -H "Host: foo" $GATEWAY_URL/posts
```
