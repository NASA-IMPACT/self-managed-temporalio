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
