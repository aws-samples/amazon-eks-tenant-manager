import yaml
import file
import base.schema as s

tenant_file = option("TENANT_FILE") or ""

if not tenant_file:
    assert "TENANT_FILE environment variable is required"

print("Processing tenant file: ${tenant_file}")

tenant_data = yaml.decode(file.read(tenant_file))

# Validate tenant data structure
assert tenant_data, "Empty tenant configuration"
assert tenant_data.name, "Tenant name is required"
assert tenant_data.env, "Tenant environment is required"
assert tenant_data.namespaces, "Tenant namespaces are required"

# Create tenant with validation
tenant = s.Tenant {
    name = str(tenant_data.name)
    env = str(tenant_data.env)
    prefix = "${tenant_data.name}-${tenant_data.env}"
    namespaces = [str(ns) for ns in tenant_data.namespaces]
    
    # Add labels and annotations if they exist
    if tenant_data.labels:
        labels = {str(k): str(v) for k, v in tenant_data.labels}
    if tenant_data.annotations:
        annotations = {str(k): str(v) for k, v in tenant_data.annotations}
    
    resourceQuota = s.ResourceQuota {
        cpu = tenant_data?.resourceQuota?.cpu
        memory = tenant_data?.resourceQuota?.memory
        pods = tenant_data?.resourceQuota?.pods
        services = tenant_data?.resourceQuota?.services
        configmaps = tenant_data?.resourceQuota?.configmaps
        secrets = tenant_data?.resourceQuota?.secrets
    }
    limitRange = s.LimitRange {
        default = s.ContainerLimits {
            cpu = tenant_data?.limitRange?.default?.cpu
            memory = tenant_data?.limitRange?.default?.memory
        }
        defaultRequest = s.ContainerLimits {
            cpu = tenant_data?.limitRange?.defaultRequest?.cpu
            memory = tenant_data?.limitRange?.defaultRequest?.memory
        }
        max = s.ContainerLimits {
            cpu = tenant_data?.limitRange?.max?.cpu
            memory = tenant_data?.limitRange?.max?.memory
        }
    }
    accessControl = s.AccessControl {
        groups = [s.AccessGroup {
            name = group.name
            type = group.type
            namespacePattern = group.namespacePattern
            iamRoles = [s.IamRole {
                roleArn = role.roleArn
                username = role.username
            } for role in group.iamRoles]
        } for group in tenant_data.accessControl.groups]
    }
    # Add applications if they exist in the input
    if tenant_data.applications:
        applications = [s.Application {
            name = app.name
            gitRepo = s.GitRepo {
                url = app.gitRepo.url
                path = app.gitRepo.path
                branch = app.gitRepo?.branch or "main"
                targetNamespace = app.gitRepo.targetNamespace
            }
        } for app in tenant_data.applications]
}