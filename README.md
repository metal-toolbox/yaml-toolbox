# yaml-toolbox

A toolbox for working wit ze yamlz

## Inventory of tools

| Name                                                      | Version   | License                                                                        | Description                                                                           |
| --------------------------------------------------------- | --------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| [helm](https://github.com/helm/helm)                      | `v3.9`    | [Apache 2.0](https://github.com/helm/helm/blob/main/LICENSE)                   | The Kubernetes Package Manager                                                        |
| [kubectl](https://github.com/kubernetes/kubectl)          | `v1.24.1` | [Apache 2.0](https://github.com/kubernetes/kubectl/blob/master/LICENSE)        | The designated kubernetes CLI client                                                  |
| [kubesec](https://github.com/controlplaneio/kubesec)      | `v2.11.4` | [Apache 2.0](https://github.com/controlplaneio/kubesec/blob/master/LICENSE)    | Security risk analysis for Kubernetes resources                                       |
| [kube-score](https://github.com/zegl/kube-score)          | `v1.14.0` | [Apache 2.0](https://github.com/zegl/kube-score/blob/master/LICENSE)           | Kubernetes object analysis with recommendations for improved reliability and security |
| [kustomize](https://github.com/kubernetes-sigs/kustomize) | `v4.5.5`  | [Apache 2.0](https://github.com/kubernetes-sigs/kustomize/blob/master/LICENSE) | Customization of kubernetes YAML configurations |
| [kubeaudit](https://github.com/Shopify/kubeaudit) | `v0.16.0`  | [MIT](hhttps://github.com/Shopify/kubeaudit/blob/main/LICENSE) | Audit Kubernetes clusters for various different security concerns |
| [kube-linter](https://github.com/stackrox/kube-linter) | `v0.2.6`  | [Apache 2.0](https://github.com/stackrox/kube-linter/blob/main/LICENSE) | Checks Kubernetes YAML and helm charts against a variety of best practices, with a focus on production readiness and security |
| [kubeconform](https://github.com/yannh/kubeconform) | `v0.4.13`  | [Apache 2.0](https://github.com/yannh/kubeconform/blob/master/LICENSE) | Kubeconform is a Kubernetes manifests validation tool |

## Usage

```
docker build -t yaml-toolbox .
docker run --rm -it -v `pwd`:/src yaml-toolbox
```

### kube-score

```
/src $  wget https://k8s.io/examples/controllers/nginx-deployment.yaml
Connecting to k8s.io (34.107.204.206:443)
Connecting to kubernetes.io (147.75.40.148:443)
saving to 'nginx-deployment.yaml'
'nginx-deployment.yaml' saved
/src $ kube-score score *.yaml
apps/v1/Deployment nginx-deployment                                           💥
    [CRITICAL] Container Image Pull Policy
        · nginx -> ImagePullPolicy is not set to Always
            It's recommended to always set the ImagePullPolicy to Always, to make sure that the imagePullSecrets are always correct, and
            to always get the image you want.
    [CRITICAL] Container Security Context User Group ID
        · nginx -> Container has no configured security context
            Set securityContext to run the container in a more secure context.
    [CRITICAL] Container Security Context ReadOnlyRootFilesystem
        · nginx -> Container has no configured security context
            Set securityContext to run the container in a more secure context.
    [CRITICAL] Container Resources
        · nginx -> CPU limit is not set
            Resource limits are recommended to avoid resource DDOS. Set resources.limits.cpu
        · nginx -> Memory limit is not set
            Resource limits are recommended to avoid resource DDOS. Set resources.limits.memory
        · nginx -> CPU request is not set
            Resource requests are recommended to make sure that the application can start and run without crashing. Set
            resources.requests.cpu
        · nginx -> Memory request is not set
            Resource requests are recommended to make sure that the application can start and run without crashing. Set
            resources.requests.memory
    [CRITICAL] Container Ephemeral Storage Request and Limit
        · nginx -> Ephemeral Storage limit is not set
            Resource limits are recommended to avoid resource DDOS. Set resources.limits.ephemeral-storage
    [CRITICAL] Pod NetworkPolicy
        · The pod does not have a matching NetworkPolicy
            Create a NetworkPolicy that targets this pod to control who/what can communicate with this pod. Note, this feature needs to
            be supported by the CNI implementation used in the Kubernetes cluster to have an effect.
    [CRITICAL] Deployment has PodDisruptionBudget
        · No matching PodDisruptionBudget was found
            It's recommended to define a PodDisruptionBudget to avoid unexpected downtime during Kubernetes maintenance operations, such
            as when draining a node.
    [WARNING] Deployment has host PodAntiAffinity
        · Deployment does not have a host podAntiAffinity set
            It's recommended to set a podAntiAffinity that stops multiple pods from a deployment from being scheduled on the same node.
            This increases availability in case the node becomes unavailable.
```

### kubesec

/src $ kubesec scan *.yaml
[
  {
    "object": "Deployment/nginx-deployment.default",
    "valid": true,
    "fileName": "nginx-deployment.yaml",
    "message": "Passed with a score of 0 points",
    "score": 0,
    "scoring": {
      "advise": [
        {
          "id": "ApparmorAny",
          "selector": ".metadata .annotations .\"container.apparmor.security.beta.kubernetes.io/nginx\"",
          "reason": "Well defined AppArmor policies may provide greater protection from unknown threats. WARNING: NOT PRODUCTION READY",
          "points": 3
        },
        {
          "id": "ServiceAccountName",
          "selector": ".spec .serviceAccountName",
          "reason": "Service accounts restrict Kubernetes API access and should be configured with least privilege",
          "points": 3
        },
        {
          "id": "SeccompAny",
          "selector": ".metadata .annotations .\"container.seccomp.security.alpha.kubernetes.io/pod\"",
          "reason": "Seccomp profiles set minimum privilege and secure against unknown threats",
          "points": 1
        },
        {
          "id": "LimitsCPU",
          "selector": "containers[] .resources .limits .cpu",
          "reason": "Enforcing CPU limits prevents DOS via resource exhaustion",
          "points": 1
        },
        {
          "id": "LimitsMemory",
          "selector": "containers[] .resources .limits .memory",
          "reason": "Enforcing memory limits prevents DOS via resource exhaustion",
          "points": 1
        },
        {
          "id": "RequestsCPU",
          "selector": "containers[] .resources .requests .cpu",
          "reason": "Enforcing CPU requests aids a fair balancing of resources across the cluster",
          "points": 1
        },
        {
          "id": "RequestsMemory",
          "selector": "containers[] .resources .requests .memory",
          "reason": "Enforcing memory requests aids a fair balancing of resources across the cluster",
          "points": 1
        },
        {
          "id": "CapDropAny",
          "selector": "containers[] .securityContext .capabilities .drop",
          "reason": "Reducing kernel capabilities available to a container limits its attack surface",
          "points": 1
        },
        {
          "id": "CapDropAll",
          "selector": "containers[] .securityContext .capabilities .drop | index(\"ALL\")",
          "reason": "Drop all capabilities and add only those required to reduce syscall attack surface",
          "points": 1
        },
        {
          "id": "ReadOnlyRootFilesystem",
          "selector": "containers[] .securityContext .readOnlyRootFilesystem == true",
          "reason": "An immutable root filesystem can prevent malicious binaries being added to PATH and increase attack cost",
          "points": 1
        },
        {
          "id": "RunAsNonRoot",
          "selector": "containers[] .securityContext .runAsNonRoot == true",
          "reason": "Force the running image to run as a non-root user to ensure least privilege",
          "points": 1
        },
        {
          "id": "RunAsUser",
          "selector": "containers[] .securityContext .runAsUser -gt 10000",
          "reason": "Run as a high-UID user to avoid conflicts with the host's user table",
          "points": 1
        }
      ]
    }
  }
]

### kubeconform

/src $ kubeconform -summary *.yaml
Summary: 1 resource found in 1 file - Valid: 1, Invalid: 0, Errors: 0, Skipped: 0