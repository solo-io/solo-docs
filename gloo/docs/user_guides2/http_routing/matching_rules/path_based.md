---
title: Path Based
weight: 1
---

There are three options to do HTTP path matching. You can specify only one of the following three options within any given
route matcher spec:
* `prefix` - match if the beginning path of request path matches specified path.
* `exact` - match if request path matches specified path exactly.
* `regex` - match if the specified regular expression matches. 

For more details, check out the [Matcher API doc]({{% ref "/v1/github.com/solo-io/gloo/projects/gloo/api/v1/proxy.proto.sk#matcher" %}})
and [Envoy doc](https://www.envoyproxy.io/docs/envoy/latest/api-v2/api/v2/route/route.proto#envoy-api-msg-route-routematch).
Full details of regular expression grammar are at <https://en.cppreference.com/w/cpp/regex/ecmascript>.

## Prefix Matching

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

Now let's create a virtual service and route to that upstream:

```shell
glooctl create vs --name test-matchers --namespace gloo-system --domains foo
glooctl add route --name test-matchers --path-prefix / --dest-name json-upstream
```

We can do `kubectl edit vs default -n gloo-system` and update the virtual service spec to look like this: 

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: test-matchers
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    name: gloo-system.default
    routes:
    - matcher:
        prefix: /
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
```

Since we are using the "foo" domain, if we make a curl request and don't provide the `Host` header, it will 404. 

```shell
curl -v $GATEWAY_URL/posts
```

If we pass the `Host` header, we will successfully get results. 

```shell
curl -H "Host: foo" $GATEWAY_URL/posts
```

## Exact matching

If we change to an exact match, this command will return a 404 again. 

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: test-matchers
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    name: gloo-system.default
    routes:
    - matcher:
        exact: /
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
```

```shell
curl -v -H "Host: foo" $(glooctl proxy url)/posts
```
Returns a 404

But if we update the path for exact matching to `/posts`, it will succeed:

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: default
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    name: gloo-system.default
    routes:
    - matcher:
        exact: /posts
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
```

```shell
curl -v -H "Host: foo" $(glooctl proxy url)/posts
```

Now returns results.

## Regex Matching

Finally, let's update the matcher to use a regex on any 5-character string consisting of lowercase letters. 

```yaml
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: default
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - 'foo'
    name: gloo-system.default
    routes:
    - matcher:
        regex: /[a-z]{5}
      routeAction:
        single:
          upstream:
            name: json-upstream
            namespace: gloo-system
```

```shell
curl -v -H "Host: foo" $(glooctl proxy url)/comments
```

Doesn't return results, but:

```shell
curl -v -H "Host: foo" $(glooctl proxy url)/posts
```

and 

```shell
curl -v -H "Host: foo" $(glooctl proxy url)/todos
```

do. 

## Summary

In this tutorial, we created a static upstream and added a route on a virtual service to point to it. We learned how to 
use all 3 types of matchers allowed by Gloo when determining if a route configuration matches a request path: 
prefix, exact, and regex. 

## Cleanup

Cleanup the virtual service and upstream:

`glooctl delete vs test-path-prefix -n gloo-system`
`glooctl delete upstream json-upstream -n gloo-system`
