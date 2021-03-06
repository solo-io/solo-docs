
---
title: "glooshot.proto"
weight: 5
---

<!-- Code generated by solo-kit. DO NOT EDIT. -->


### Package: `glooshot.solo.io` 
#### Types:


- [Experiment](#experiment) **Top-Level Resource**
- [ExperimentResult](#experimentresult)
- [State](#state)
- [ExperimentSpec](#experimentspec)
- [InjectedFault](#injectedfault)
- [FailureCondition](#failurecondition)
- [PrometheusTrigger](#prometheustrigger)
- [SuccessRateQuery](#successratequery)
  



##### Source File: [github.com/solo-io/glooshot/api/v1/glooshot.proto](https://github.com/solo-io/glooshot/blob/master/api/v1/glooshot.proto)





---
### Experiment

 
Describes an Experiment that GlooShot should run

```yaml
"metadata": .core.solo.io.Metadata
"status": .core.solo.io.Status
"spec": .glooshot.solo.io.ExperimentSpec
"result": .glooshot.solo.io.ExperimentResult

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `metadata` | [.core.solo.io.Metadata](../../../../solo-kit/api/v1/metadata.proto.sk#metadata) | the object metadata for this resource |  |
| `status` | [.core.solo.io.Status](../../../../solo-kit/api/v1/status.proto.sk#status) | indicates whether or not the spec is valid set by glooshot, intended to be read by clients |  |
| `spec` | [.glooshot.solo.io.ExperimentSpec](../glooshot.proto.sk#experimentspec) | configuration for the Experiment |  |
| `result` | [.glooshot.solo.io.ExperimentResult](../glooshot.proto.sk#experimentresult) | the result of the experiment |  |




---
### ExperimentResult



```yaml
"state": .glooshot.solo.io.ExperimentResult.State
"failureReport": map<string, string>
"timeStarted": .google.protobuf.Timestamp
"timeFinished": .google.protobuf.Timestamp

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `state` | [.glooshot.solo.io.ExperimentResult.State](../glooshot.proto.sk#state) | the current state of the experiment as reported by glooshot |  |
| `failureReport` | `map<string, string>` | arbitrary data summarizing a failure in case one occurred |  |
| `timeStarted` | [.google.protobuf.Timestamp](https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/timestamp) | time the experiment was started |  |
| `timeFinished` | [.google.protobuf.Timestamp](https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/timestamp) | the time the experiment completed |  |




---
### State



| Name | Description |
| ----- | ----------- | 
| `Pending` | Experiment has not started |
| `Started` | Experiment started but threshold not met |
| `Failed` | Experiment failed, threshold was exceeded |
| `Succeeded` | Experiment succeeded, duration elapsed If duration is not specified, the Experiment will never be marked Succeeded |




---
### ExperimentSpec



```yaml
"faults": []glooshot.solo.io.ExperimentSpec.InjectedFault
"failureConditions": []glooshot.solo.io.FailureCondition
"duration": .google.protobuf.Duration
"targetMesh": .core.solo.io.ResourceRef

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `faults` | [[]glooshot.solo.io.ExperimentSpec.InjectedFault](../glooshot.proto.sk#injectedfault) | the faults this experiment will inject if empty, Glooshot will run a "control" experiment with no faults injected |  |
| `failureConditions` | [[]glooshot.solo.io.FailureCondition](../glooshot.proto.sk#failurecondition) | conditions on which to stop the experiment and mark it as failed at least one must be specified |  |
| `duration` | [.google.protobuf.Duration](https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/duration) | the duration for which to run the experiment if missing or set to 0 the experiment will run indefinitely only Experiments with a timeout can succeed |  |
| `targetMesh` | [.core.solo.io.ResourceRef](../../../../solo-kit/api/v1/ref.proto.sk#resourceref) | The mesh to which the experiment will be applied. Must match a mesh.supergloo.solo.io CRD. If a cluster only has a single mesh, this value is not needed, Glooshot will default to the only possible option. |  |




---
### InjectedFault

 
decribes a single fault to  inject

```yaml
"originServices": []core.solo.io.ResourceRef
"destinationServices": []core.solo.io.ResourceRef
"fault": .supergloo.solo.io.FaultInjection

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `originServices` | [[]core.solo.io.ResourceRef](../../../../solo-kit/api/v1/ref.proto.sk#resourceref) | if specified, the fault will only apply to requests sent from these services |  |
| `destinationServices` | [[]core.solo.io.ResourceRef](../../../../solo-kit/api/v1/ref.proto.sk#resourceref) | if specified, the fault will only apply to requests sent to these services |  |
| `fault` | [.supergloo.solo.io.FaultInjection](../../../../supergloo/api/v1/routing.proto.sk#faultinjection) | the type of fault to inject |  |




---
### FailureCondition

 
a condition based on an observed prometheus metric

```yaml
"webhookUrl": string
"prometheusTrigger": .glooshot.solo.io.PrometheusTrigger

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `webhookUrl` | `string` | if HTTP GET returns non-200 status code, the condition was met |  |
| `prometheusTrigger` | [.glooshot.solo.io.PrometheusTrigger](../glooshot.proto.sk#prometheustrigger) | trigger a failure on observed prometheus metric |  |




---
### PrometheusTrigger



```yaml
"customQuery": string
"successRate": .glooshot.solo.io.PrometheusTrigger.SuccessRateQuery
"thresholdValue": float
"comparisonOperator": string

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `customQuery` | `string` | a user-specified query as an inline string |  |
| `successRate` | [.glooshot.solo.io.PrometheusTrigger.SuccessRateQuery](../glooshot.proto.sk#successratequery) | query the success rate for a specific service |  |
| `thresholdValue` | `float` | consider the failure condition met if the metric falls below this threshold |  |
| `comparisonOperator` | `string` | the comparison operator to use when comparing the threshold and observed metric values if the comparison evaluates to true, the failure condition will be considered met possible values are '==', '>', '<', '>=', and '<=' defaults to '<' |  |




---
### SuccessRateQuery

 
returns the # of non-5XX requests / total requests for the given interval

```yaml
"service": .core.solo.io.ResourceRef
"interval": .google.protobuf.Duration

```

| Field | Type | Description | Default |
| ----- | ---- | ----------- |----------- | 
| `service` | [.core.solo.io.ResourceRef](../../../../solo-kit/api/v1/ref.proto.sk#resourceref) | the service whose success rate Glooshot should monitor |  |
| `interval` | [.google.protobuf.Duration](https://developers.google.com/protocol-buffers/docs/reference/csharp/class/google/protobuf/well-known-types/duration) | the time interval over which the success rate should be measured defaults to 1 minute |  |





<!-- Start of HubSpot Embed Code -->
<script type="text/javascript" id="hs-script-loader" async defer src="//js.hs-scripts.com/5130874.js"></script>
<!-- End of HubSpot Embed Code -->
