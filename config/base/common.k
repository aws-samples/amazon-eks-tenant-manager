COMMON_LABELS = {
    "managed-by": "kcl"
    "app.kubernetes.io/managed-by": "kcl"
    "app.kubernetes.io/created-by": "kcl-plugin"
}

COMMON_ANNOTATIONS = {
    "kcl-plugin.kubernetes.io/version": "v1.0"
}

mergeLabels = lambda labels: {str:str} {
    COMMON_LABELS | labels
}

mergeAnnotations = lambda annotations: {str:str} {
    COMMON_ANNOTATIONS | annotations
}