# ConfigMap containing PostgreSQL initialization script
# Creates the visibility database needed by Temporal for advanced querying
resource "kubernetes_config_map_v1" "postgres_init" {
  metadata {
    name      = "postgres-init-script"
    namespace = var.namespace
  }

  data = {
    "init.sql" = <<-EOT
      CREATE DATABASE ${var.temporal_visibility_db_name};
    EOT
  }
}



# Kubernetes secret storing PostgreSQL credentials
# Used by both the PostgreSQL deployment and Temporal services
resource "kubernetes_secret_v1" "temporal_postgres_secret" {
  metadata {
    name      = "${var.temporal_db_name}-secret"
    namespace = var.namespace
  }

  data = {
    user     = var.temporal_db_user
    password = var.temporal_db_password
  }

  type = "Opaque"
}
