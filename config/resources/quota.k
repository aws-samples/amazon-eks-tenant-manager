import base.config
import base.common

quotas = [{
    metadata = {
        name = "${config.tenant.prefix}-${ns}-quota"  # Add environment suffix
        namespace = "${config.tenant.prefix}-${ns}"    # Match namespace name
        labels = common.mergeLabels({
            "team": config.tenant.name
        })
        annotations = common.mergeAnnotations({
            "team.kubernetes.io/resource-quota": "true"
        })
    }
    spec = {
        hard = {
            "cpu": config.tenant.resourceQuota.cpu
            "memory": config.tenant.resourceQuota.memory
            "pods": config.tenant.resourceQuota.pods
            "services": config.tenant.resourceQuota.services
            "configmaps": config.tenant.resourceQuota.configmaps
            "secrets": config.tenant.resourceQuota.secrets
        }
    }
} for ns in config.tenant.namespaces]