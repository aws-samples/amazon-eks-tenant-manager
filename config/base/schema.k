schema ResourceQuota:
    cpu?: str = "4"
    memory?: str = "8Gi"
    pods?: str = "20"
    services?: str = "10"
    configmaps?: str = "20"
    secrets?: str = "20"

schema ContainerLimits:
    cpu: str
    memory: str

schema LimitRange:
    default: ContainerLimits = {
        cpu = "500m"
        memory = "512Mi"
    }
    defaultRequest: ContainerLimits = {
        cpu = "100m"
        memory = "128Mi"
    }
    max: ContainerLimits = {
        cpu = "2"
        memory = "2Gi"
    }

schema GitRepo:
    url: str
    path: str
    branch?: str = "main"
    targetNamespace: str

schema Application:
    name: str
    gitRepo: GitRepo

schema AccessGroup:
    name: str
    type: str
    namespacePattern: str
    iamRoles: [IamRole]

schema IamRole:
    roleArn: str
    username: str

schema AccessControl:
    groups: [AccessGroup]

schema Tenant:
    name: str
    env: str
    prefix: str
    namespaces: [str]
    labels?: {str:str} = {}
    annotations?: {str:str} = {}
    resourceQuota: ResourceQuota
    limitRange: LimitRange
    accessControl: AccessControl
    applications?: [Application]