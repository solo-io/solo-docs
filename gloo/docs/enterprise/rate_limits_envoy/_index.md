---
title: Envoy Rate Limits
weight: 3
---

In this document we will show how to use Gloo with Rate limits.

Gloo enterprise comes with a rate limit server based off of lyft's rate-limit server.
It is already installed when doing `gloo install gateway --license-key=...`
To get your trial license key, go to: https://www.solo.io/glooe-trial

Gloo supports two modes of rate limits:

- A simple mode that allows configuring limits for authenticated (as defined by the gloo auth plugin) and anonymous requests.
- A custom mode that allows configuring limits with the native envoy configuration language.

In this document we will describe the second option (The first option is easily accessible via the ui, and described in [this doc](../ratelimit)).

## Setup - Instaling gloo 
This is covered by other parts of the documented, here is the quick version:

```bash
$ glooctl install gateway --license-key=<YOUR KEY>
```

Install the pet clinic demo app:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/solo-io/gloo/master/example/petclinic/petclinic.yaml
```

Add a route to the petclinic demo app:

```bash
$ glooctl add route --name default --namespace gloo-system --path-prefix / --dest-name default-petclinic-8080 --dest-namespace gloo-system
```

Check that everything is in order:
```bash
$ URL=$(glooctl proxy url)
$ curl --head $URL 
HTTP/1.1 200 OK
content-type: text/html;charset=UTF-8
content-language: en
content-length: 3939
date: Sun, 17 Mar 2019 15:42:04 GMT
x-envoy-upstream-service-time: 13
server: envoy
```

## Configuring Envoy Rate Limits

The glooctl command line will open a text editor so you can write your custom configuration directly.
To use your favorite editor, set the *EDITOR* environment variable.

For example, when using vscode:
```
$ export EDITOR="code -r -w"
```

### Edit Rate Limit Server Settings
Edit the rate limit server settings:
```
$ glooctl edit settings --namespace gloo-system --name default ratelimit custom-server-config
```
And paste the contents of [serverconfig.yaml](serverconfig.yaml) there.

### Edit Virtual Service Rate Limit Settings

Edit the virtual service settings:

```
$ glooctl edit virtualservice --namespace gloo-system --name default ratelimit custom-envoy-config
```

And paste the contents of [vsconfig.yaml](vsconfig.yaml) there.

### Test

Run `curl --head $URL` a few times. You will soon see that curl is rate limited:

```bash
$ curl --head $URL 
HTTP/1.1 429 Too Many Requests
x-envoy-ratelimited: true
date: Sun, 17 Mar 2019 15:42:17 GMT
server: envoy
transfer-encoding: chunked
```
## Conclusion
With the custom rate-limit configuration option, you have the full power of Envoy rate limits to use for your custom use cases.