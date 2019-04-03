---
title: Custom Auth
weight: 2
description: External Authentication With your own auth server
---
While Gloo provides an auth server that covers your OpenID Connect and Basic Auth use cases, it also 
allows your to use your own authetication server, to implement custom auth logic.

In this guide we will demonstrate your to create and configure gloo to use your own auth service.
For simplicity we will use an http service. Though this guide will work (with minor adjuestments) also work with a gRPC server that implements
the Envoy spec for an [external authorization server](https://github.com/envoyproxy/envoy/blob/master/api/envoy/service/auth/v2/external_auth.proto).

Let's get right to it!

## Deploy authentication service

For reference, this is the codee for the authentication server we are using:
```python
import http.server
import socketserver

class Server(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = self.path
        print("path", path)
        if path.startswith("/api/pets/1"):
            self.send_response(200, 'OK')
        else:
            self.send_response(401, 'Not authorized')
        self.send_header('x-server', 'pythonauth')
        self.end_headers()

def serve_forever(port):
    socketserver.TCPServer(('', port), Server).serve_forever()

if __name__ == "__main__":
    serve_forever(8000)
```

As you can see, this service will allow requests to `/api/pets/1` and will deny everything else.

{{% notice tip %}}
You can easily change the sample auth server. When using minikube, download the [Dockerfile](Dockerfile) and the [server code](server.py) and just run:
```shell
eval $(minikube docker-env)
docker build -t quay.io/solo-io/sample-auth .
kubectl delete pod -n gloo-system -l app=sample-auth
```
{{% /notice %}}

To add this service to your cluster, download the [auth-service yaml](auth-service.yaml) and apply it:
```
kubectl apply -f auth-service.yaml
```

## Deploy Gloo and the petstore demo app

Install Gloo-enterprise (version v0.13.5 or above) and the petstore demo:
```shell
glooctl install gateway --license-key <YOUR KEY>
kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/master/example/petstore/petstore.yaml
```

Add a route and test that everything so far works:

```shell
glooctl add route --name default --namespace gloo-system --path-prefix / --dest-name default-petstore-8080 --dest-namespace gloo-system
URL=$(glooctl proxy url)
curl $URL/api/pets/
[{"id":1,"name":"Dog","status":"available"},{"id":2,"name":"Cat","status":"pending"}]
```

## Configure Gloo to use your server

### Configure Gloo settings

Edit the gloo settings (`kubectl edit settings -n gloo-system default`) to point to your auth server. settings should look like this:

{{< highlight yaml "hl_lines=9-18" >}}
apiVersion: gloo.solo.io/v1
kind: Settings
metadata:
  name: default
  namespace: gloo-system
spec:
  bindAddr: 0.0.0.0:9977
  discoveryNamespace: gloo-system
  extensions:
    configs:
      extauth:
        extauthzServerRef:
          name: auth-server
          namespace: gloo-system
        httpService: {}
        requestBody:
          maxRequestBytes: 10240
        requestTimeout: 0.5s
      rate-limit:
        ratelimit_server_ref:
          name: rate-limit
          namespace: gloo-system
  kubernetesArtifactSource: {}
  kubernetesConfigSource: {}
  kubernetesSecretSource: {}
  refreshRate: 60s
{{< /highlight >}}

{{% notice tip %}}
When using a gRPC auth service, remove the `httpService: {}` line from the config above.
{{% /notice %}}

This configuration also sets other configuraiton parameters:

- requestBody - When set to, the request body will also be sent to the auth service. with this configuration, a body up to 10KB will be buffered and sent to the auth-service. This is useful in use cases where the auth service needs to compute an HMAC on the body.
- requestTimeout - A timeout for the auth service response. If the service takes longer to response, the request will be denied.

### Configure the virtual service

Edit the virtual service (`kubectl edit virtualservice -n gloo-system default`), and mark it with custom auth to turn authentication on. virtual service should look like this:

{{< highlight yaml "hl_lines=10-14" >}}
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: default
  namespace: gloo-system
spec:
  virtualHost:
    domains:
    - '*'
    virtualHostPlugins:
      extensions:
        configs:
          extauth:
            customAuth: {}
    routes:
    - matcher:
        prefix: /
      routeAction:
        single:
          upstream:
            name: default-petstore-8080
            namespace: gloo-system
{{< /highlight >}}

To make it easy, if you have followed this guide verbatim, you can just download and apply [this](gloo-vs.yaml) manifest to update both settings and virtual service.

## Test

We are all set to test!
```shell
curl -w "%{http_code}\n"  $URL/api/pets/1
{"id":1,"name":"Dog","status":"available"}
200

curl -w "%{http_code}\n"  $URL/api/pets/2 
401
```

## Conclusion

Gloo's extendable architecture allows follows the 'batties included but replacable' approach.
while you can use Gloo's built in auth services for OpenID Connect and Basic Auth, you can also
extend Gloo with your own custom auth logic.