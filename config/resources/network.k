import base.config as config
import base.common

# Define allowed shared services
SHARED_NAMESPACES = [
    {
        "namespace": "kube-system"
        "ports": [
            {
                "port": 53
                "protocol": "UDP"
            }
            {
                "port": 53
                "protocol": "TCP"
            }
        ]
    }
    {
        "namespace": "monitoring"
        "ports": [
            {
                "port": 9090
                "protocol": "TCP"
            }
        ]
    }
    {
        "namespace": "logging"
        "ports": [
            {
                "port": 24224
                "protocol": "TCP"
            }
        ]
    }
]

# Deny-all policies (one per namespace)
deny_all_policies = [{
    metadata = {
        name = "${config.tenant.prefix}-${ns}-deny-all"
        namespace = "${config.tenant.prefix}-${ns}"
        labels = common.mergeLabels({
            "team": config.tenant.name
            "policy-type": "deny-all"
        })
        annotations = common.mergeAnnotations({
            "networkpolicy.kubernetes.io/description": "Deny all ingress and egress traffic by default"
        })
    }
    spec = {
        podSelector = {}
        policyTypes = ["Ingress", "Egress"]
    }
} for ns in config.tenant.namespaces]

# Allow shared services policies
shared_services_policies = [{
    metadata = {
        name = "${config.tenant.prefix}-${ns}-shared-services"
        namespace = "${config.tenant.prefix}-${ns}"
        labels = common.mergeLabels({
            "team": config.tenant.name
            "policy-type": "shared-services"
        })
        annotations = common.mergeAnnotations({
            "networkpolicy.kubernetes.io/description": "Allow access to shared services and intra-tenant communication"
        })
    }
    spec = {
        podSelector = {}
        policyTypes = ["Ingress", "Egress"]
        
        # Allow only from same tenant namespaces
        ingress = [{
            from = [{
                namespaceSelector = {
                    matchLabels = {
                        "team": config.tenant.name
                        "environment": config.tenant.env
                    }
                }
            }]
        }]
        
        # Create egress rules
        egress = [
            # First rule: Same tenant access
            {
                to = [{
                    namespaceSelector = {
                        matchLabels = {
                            "team": config.tenant.name
                            "environment": config.tenant.env
                        }
                    }
                }]
            }
        ] + [
            # Additional rules: One for each shared service
            {
                to = [{
                    namespaceSelector = {
                        matchLabels = {
                            "kubernetes.io/metadata.name": service.namespace
                        }
                    }
                }]
                ports = service.ports
            } for service in SHARED_NAMESPACES
        ]
    }
} for ns in config.tenant.namespaces]

# Combine all policies
all_policies = deny_all_policies + shared_services_policies