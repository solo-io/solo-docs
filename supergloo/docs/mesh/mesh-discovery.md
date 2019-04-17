---
title: "Mesh Discovery"
weight: 2
---

# Overview

Mesh discovery is the ability to discovery service meshes which are running in the cluster to which mesh
discovery is deployed. This capability is currently shipped with supergloo by default, but in the future
will be available as a standalone feature.

Currently supported meshes for Discovery:

- Istio

# Architecture

Mesh discovery, similar to other solo.io projects, uses an event loop based architecure to watch kubernetes 
resources to create/update those resources. In this case we are interested in three resources:

* [Mesh](../v1/github.com/solo-io/supergloo/api/v1/mesh.proto.sk.md)
* [Install](../v1/github.com/solo-io/supergloo/api/v1/install.proto.sk.md)
* [Pod](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.11/#pod-v1-core) (kubernetes resource)

More information about these resources can be found by clicking the links above. 

At it's core mesh discovery monitors these resources and takes actions based on certain heuristics. These heuristics 
vary slightly by the type of mesh we are trying to discover, but the concept is similar. For example, in the case of istio: 
mesh discovery watches for the existence of istio-pilot pods and creates mesh crds based on the internals of those pods.
The heuristics we chose are based on our experience working with multiple service meshes.

#### Advanced Config

In order to observe/discover more advanced information, mesh discovery requires the ability to monitor custom resources (CRDs)
on a per mesh basis. In order to accomplish this mesh discovery creates new watches for mesh specific resources when/if a mesh 
CRD for a given mesh is found. For instance, if an istio mesh is discovered, and an istio mesh CRD is created, then mesh 
discovery will begin to monitor istio specific resources in order to gather more fine grained details about the particular 
istio deployment.

{{<mermaid>}}
graph TB;
    cli1 ---|writes| crd2
    subgraph cli/kubectl
        cli1[User/System]
    end
    md2 ---|spanws| md3
    md1 ---|writes| crd1
    md2 ---|reads| crd1
    md1 ---|reads| crd2
    subgraph mesh-discovery
        md1[Discovery Event Loop]
        md2[Discovery Registration Loop]
        md3[Istio Config Loop]
    end
    sg1 ---|reads| crd2
    subgraph custom-resources
        crd1(Mesh CRD)
        crd2(Install CRD)
    end
    subgraph supergloo
        sg1[Install Event Loop]
    end
{{< /mermaid >}}

The above diagram is an approximation of this system working in practice. The lines do not represent order exactly as all of the parts 
of the system are running concurrently, but it still gives an idea of how the different pieces are created and consumed.

