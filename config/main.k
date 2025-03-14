import resources.namespace as namespace_res
import resources.quota as quota_res
import resources.limits as limits_res
import resources.network as network_res
import resources.rbac as rbac
import resources.applicationset as applicationset
import resources.argocd_project as argocd_project


{
    apiVersion = "v1"
    kind = "List"
    items = [
        # ArgoCD Project
        *argocd_project.argocd_project
    ] + [
        # Namespaces
        {
            apiVersion = "v1"
            kind = "Namespace"
            metadata = ns.metadata
        } for ns in namespace_res.namespaces
    ] + [
        # Resource Quotas
        {
            apiVersion = "v1"
            kind = "ResourceQuota"
            metadata = quota.metadata
            spec = quota.spec
        } for quota in quota_res.quotas
    ] + [
        # Limit Ranges
        {
            apiVersion = "v1"
            kind = "LimitRange"
            metadata = limit.metadata
            spec = limit.spec
        } for limit in limits_res.limits
    ] + [
        # Network Policies
        {
            apiVersion = "networking.k8s.io/v1"
            kind = "NetworkPolicy"
            metadata = policy.metadata
            spec = policy.spec
        } for policy in network_res.all_policies
    ] + [
        # RBAC Resources
        *rbac.rbac_resources
    ] + [
        # ApplicationSets (if applications are defined)
        *applicationset.applicationsets
    ]
}