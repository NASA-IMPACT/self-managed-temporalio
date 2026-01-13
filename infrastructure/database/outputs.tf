output "postgres_service_url" {
  value = "${kubernetes_service_v1.postgres.metadata[0].name}.${var.namespace}.svc.cluster.local" 
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
