
resource "kubernetes_namespace_v1" "temporalio-ns" {
  metadata {
    name = var.namespace
  }
}





module "database" {
  source                      = "./database"
  temporal_db_name            = var.temporal_db_name
  namespace                   = kubernetes_namespace_v1.temporalio-ns.metadata.0.name
  temporal_db_storage         = "10Gi"
  temporal_visibility_db_name = var.temporal_visibility_db_name
  temporal_db_user            = var.temporal_db_user
  temporal_db_password        = var.temporal_db_password
  storage_class_name          = var.storage_class_name


}



resource "local_file" "temporalio_values" {
  filename = "${path.root}/templates/values.yaml"
  content = templatefile("${path.root}/templates/values.yaml.tmpl", {
    db_plugin_name              = var.db_plugin_name
    db_driver_name              = var.db_driver_name
    temporal_db_name            = var.temporal_db_name
    temporal_db_host            = module.database.postgres_service_url
    temporal_db_port            = module.database.postgres_service_port
    temporal_db_user            = var.temporal_db_user
    temporal_db_password        = var.temporal_db_password
    temporal_visibility_db_name = var.temporal_visibility_db_name


  })
}

resource "helm_release" "temperolaio" {
  depends_on = [module.database]
  namespace  = kubernetes_namespace_v1.temporalio-ns.metadata.0.name
  name       = "temporal"
  repository = "https://go.temporal.io/helm-charts"
  chart      = "temporal"
  version    = var.temporal_chart_version

  # Helm chart deployment can sometimes take longer than the default 5 minutes
  timeout = var.timeout_seconds

  # If values file specified by the var.values_file input variable exists then apply the values from this file
  # else apply the default values from the chart
  values = [local_file.temporalio_values.content]

}



resource "kubernetes_job_v1" "temporal_namespace" {
  depends_on = [helm_release.temperolaio]

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

