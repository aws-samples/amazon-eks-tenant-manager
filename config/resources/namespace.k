import k8s.api.core.v1
import base.config
import base.common

namespaces = [{
    apiVersion = "v1"
    kind = "Namespace"
    metadata = {
        name = "${config.tenant.name}-${config.tenant.env}-${ns}"
        labels = common.mergeLabels({
            "team": config.tenant.name
            "environment": config.tenant.env
            ** (config.tenant.labels or {})  # Merge tenant-specific labels
        })
        annotations = common.mergeAnnotations({
            "team.kubernetes.io/name": config.tenant.name
            "team.kubernetes.io/environment": config.tenant.env
            ** (config.tenant.annotations or {})  # Merge tenant-specific annotations
        })
    }
} for ns in config.tenant.namespaces]