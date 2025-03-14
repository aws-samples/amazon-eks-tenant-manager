import base.config as config
import base.common as common

# Generate ArgoCD Project only if applications are defined
argocd_project = [] if not config.tenant?.applications else [
    {
        apiVersion = "argoproj.io/v1alpha1"
        kind = "AppProject"
        metadata = {
            name = config.tenant.prefix  
            namespace = "argocd"
            labels = common.mergeLabels({
                "team": config.tenant.name
                "environment": config.tenant.env
            })
            annotations = {
                "argocd.argoproj.io/sync-wave": "-1"
            }
        }
        spec = {
            description = "${config.tenant.name} team applications for ${config.tenant.env} environment"
            # Include all application repos plus wildcard for team repos
            sourceRepos = [
                app.gitRepo.url for app in config.tenant.applications
            ] + [
                "https://github.com/${config.tenant.name}/*"  # Wildcard for team repos
            ]
            destinations = [
                {
                    server = "https://kubernetes.default.svc"
                    namespace = "${config.tenant.prefix}-${ns}"
                } for ns in config.tenant.namespaces
            ]
            clusterResourceWhitelist = [
                {
                    group = ""
                    kind = "Namespace"
                }
            ]
            namespaceResourceWhitelist = [
                {
                    group = "*"
                    kind = "*"
                }
            ]
            roles = [
                {
                    name = "project-admin"
                    description = "Project admin role"
                    policies = [
                        "p, proj:${config.tenant.name}-${config.tenant.env}:project-admin, applications, *, ${config.tenant.name}-${config.tenant.env}/*, allow"
                    ]
                    groups = [
                        "${config.tenant.name}-admins"
                    ]
                }
                {
                    name = "project-readonly"
                    description = "Project read-only role"
                    policies = [
                        "p, proj:${config.tenant.name}-${config.tenant.env}:project-readonly, applications, get, ${config.tenant.name}-${config.tenant.env}/*, allow"
                    ]
                    groups = [
                        "${config.tenant.name}-viewers"
                    ]
                }
            ]
        }
    }
]