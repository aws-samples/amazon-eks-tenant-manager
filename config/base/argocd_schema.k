# Simple schemas for KCL 0.11.1
schema ApplicationSet:
    """
    Argo CD ApplicationSet Custom Resource
    """
    apiVersion: str = "argoproj.io/v1alpha1"
    kind: str = "ApplicationSet"
    metadata: {str:any}
    spec: {str:any}


schema ArgoCDProject:
    apiVersion: str = "argoproj.io/v1alpha1"
    kind: str = "AppProject"
    metadata: {str:any}
    spec: {str:any}