output "postgres_service_url" {
  value = "${local.temporal_db_service_name}.${var.namespace}.svc.cluster.local"
}

output "postgres_service_port" {
  value = 5432
}

output "postgres_user" {
  value = var.temporal_db_user
}

output "postgres_databases" {
  value = [var.temporal_db_name, var.temporal_visibility_db_name]
}

output "postgres_secret_name" {
  value = kubernetes_secret_v1.temporal_postgres_secret.metadata[0].name
}
