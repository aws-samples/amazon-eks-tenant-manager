import k8s.api.rbac.v1 as rbacv1
import base.config as config
import base.common as common

# Role templates
ROLE_TEMPLATES = {
    "admin": [
        {
            apiGroups = ["*"]
            resources = ["*"]
            verbs = ["*"]
        }
    ]
    "developer": [
        {
            apiGroups = [""]
            resources = ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims"]
            verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
        }
        {
            apiGroups = ["apps"]
            resources = ["deployments", "statefulsets", "daemonsets"]
            verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
        }
        {
            apiGroups = ["networking.k8s.io"]
            resources = ["ingresses"]
            verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
        }
        {
            apiGroups = ["batch"]
            resources = ["jobs", "cronjobs"]
            verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
        }
    ]
    "viewer": [
        {
            apiGroups = ["*"]
            resources = ["*"]
            verbs = ["get", "list", "watch"]
        }
    ]
}

# Generate roles
roles = [
    rbacv1.Role {
        metadata = {
            name = "${group.name}-${group.type}"
            namespace = "${config.tenant.prefix}-${ns}"
            labels = common.mergeLabels({
                "team": config.tenant.name
                "access-group": group.name
            })
        }
        rules = ROLE_TEMPLATES[group.type]
    } for group in config.tenant.accessControl.groups
    for ns in config.tenant.namespaces
]

# Generate role bindings
role_bindings = [
    rbacv1.RoleBinding {
        metadata = {
            name = "${group.name}-${group.type}"
            namespace = "${config.tenant.prefix}-${ns}"
            labels = common.mergeLabels({
                "team": config.tenant.name
                "access-group": group.name
            })
        }
        subjects = [
            {
                kind = "User"
                name = role.username
                apiGroup = "rbac.authorization.k8s.io"
            } for role in group.iamRoles
        ]
        roleRef = {
            kind = "Role"
            name = "${group.name}-${group.type}"
            apiGroup = "rbac.authorization.k8s.io"
        }
    } for group in config.tenant.accessControl.groups
    for ns in config.tenant.namespaces
]

# All RBAC resources
rbac_resources = roles + role_bindings