---
title: Installation
menuTitle: Installation
weight: 2
---

# Quick start

## Install Gloo Shot command line

### Homebrew

If you use [Homebrew](https://brew.sh), you can install `glooshot` with the following command

```shell
brew install solo-io/tap/glooshot
```

### Other

- Download the latest release of [Gloo Shot](https://github.com/solo-io/glooshot/releases)
- Rename to `glooshot`, and copy it to your path as an executable
- Configure `kubectl` to point to the cluster you want Gloo Shot to operate against, i.e., `glooshot` uses
KUBECONFIG setting to connect to Kubernetes cluster.

## Install and initialize Gloo Shot to Kubernetes

```bash
glooshot init
```
