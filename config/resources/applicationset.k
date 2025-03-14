import base.config as config
import base.common as common

applicationsets = [
    {
        apiVersion = "argoproj.io/v1alpha1"
        kind = "ApplicationSet"
        metadata = {
            name = "${config.tenant.prefix}-${app.name}"
            namespace = "argocd"
            labels = common.mergeLabels({
                "team": config.tenant.name
                "environment": config.tenant.env
            })
        }
        spec = {
            generators = [{
                list = {
                    elements = [{
                        namespace = "${config.tenant.prefix}-${app.gitRepo.targetNamespace}"
                    }]
                }
            }]
            template = {
                metadata = {
                    name = "${config.tenant.prefix}-${app.name}"
                    labels = {
                        "team": config.tenant.name
                        "environment": config.tenant.env
                    }
                }
                spec = {
                    project = config.tenant.prefix
                    source = {
                        repoURL = app.gitRepo.url
                        targetRevision = app.gitRepo.branch
                        path = app.gitRepo.path
                    }
                    destination = {
                        server = "https://kubernetes.default.svc"
                        namespace = "{{namespace}}"
                    }
                    syncPolicy = {
                        automated = {
                            prune = True
                            selfHeal = True
                        }
                        syncOptions = [
                            "CreateNamespace=false"
                            "PruneLast=true"
                        ]
                    }
                }
            }
        }
    } for app in config.tenant?.applications or []
]