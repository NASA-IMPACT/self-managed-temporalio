
# Create a dedicated Kubernetes namespace for TemporalIO components
resource "kubernetes_namespace_v1" "temporalio-ns" {
  metadata {
    name = var.namespace
  }
}





# Deploy PostgreSQL database module for TemporalIO
module "database" {
  source                      = "./database"
  temporal_db_name            = var.temporal_db_name
  namespace                   = kubernetes_namespace_v1.temporalio-ns.metadata.0.name
  temporal_db_storage         = "10Gi"
  temporal_visibility_db_name = var.temporal_visibility_db_name
  temporal_db_user            = var.temporal_db_user
  temporal_db_password        = var.temporal_db_password
  storage_class_name          = var.storage_class_name
  temporal_db_cpu_request = var.temporal_db_cpu_request
  temporal_db_cpu_limit = var.temporal_db_cpu_limit
  temporal_db_memory_limit = var.temporal_db_memory_limit
  temporal_db_memory_request = var.temporal_db_memory_request

}



# Generate dynamic Helm values file with database connection details
resource "local_file" "temporalio_values" {
  filename = "${path.module}/templates/values.yaml"
  content = templatefile("${path.module}/templates/values.yaml.tmpl", {
    db_plugin_name              = var.db_plugin_name
    db_driver_name              = var.db_driver_name
    temporal_db_name            = var.temporal_db_name
    temporal_db_host            = module.database.postgres_service_url
    temporal_db_port            = module.database.postgres_service_port
    temporal_db_user            = var.temporal_db_user
    temporal_db_password        = var.temporal_db_password
    temporal_visibility_db_name = var.temporal_visibility_db_name
    use_traefik_ingress = var.use_traefik_ingress
    domain_name = var.domain_name
  })
}

# Deploy TemporalIO using the official Helm chart
resource "helm_release" "temporalio" {
  depends_on = [module.database]
  namespace  = kubernetes_namespace_v1.temporalio-ns.metadata.0.name
  name       = "temporal"
  repository = "https://go.temporal.io/helm-charts"
  chart      = "temporal"
  version    = var.temporal_chart_version

  # Helm chart deployment can sometimes take longer than the default 5 minutes
  timeout = var.timeout_seconds

  # Apply dynamically generated values with database configuration
  values = [local_file.temporalio_values.content]
}


# Initialize Temporal by registering the default namespace
resource "kubernetes_job_v1" "temporal_namespace" {
  depends_on = [helm_release.temporalio]

  metadata {
    name      = "temporal-namespace-setup"
    namespace = kubernetes_namespace_v1.temporalio-ns.metadata.0.name
  }

  spec {
    template {
      metadata {}
      spec {
        restart_policy = "OnFailure"

        container {
          name    = "setup"
          image   = "temporalio/admin-tools:latest"
          command = ["tctl", "namespace", "register", "default", "--retention", "7"]

          env {
            name  = "TEMPORAL_CLI_ADDRESS"
            value = "temporal-frontend:7233"
          }
        }
      }
    }
    backoff_limit = 3
  }

  wait_for_completion = true

  timeouts {
    create = "5m"
    update = "5m"
  }
}


