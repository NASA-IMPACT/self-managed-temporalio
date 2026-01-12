resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "${var.temporal_db_name}-db-deployment"
    namespace = var.namespace
    labels = {
      app = "${var.temporal_db_name}-db-deployment"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.temporal_db_name}-db-deployment"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.temporal_db_name}-db-deployment"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:16"

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.temporal_postgres_secret.metadata[0].name
                key  = "user"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.temporal_postgres_secret.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "POSTGRES_DB"
            value = var.temporal_db_name
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          port {
            container_port = 5432
            name           = "postgres"
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "init-script"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", var.temporal_db_user]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", var.temporal_db_user]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }

        volume {
          name = "postgres-storage"
          persistent_volume_claim {
            claim_name = "${var.temporal_db_name}-pvc"
          }
        }

        volume {
          name = "init-script"
          config_map {
            name = kubernetes_config_map_v1.postgres_init.metadata[0].name
          }
        }
      }
    }
  }
}

locals {
  temporal_db_service_name = "${var.temporal_db_name}-db-service"
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = local.temporal_db_service_name
    namespace = var.namespace
    labels = {
      app = local.temporal_db_service_name
    }
  }

  spec {
    selector = {
      app = "${var.temporal_db_name}-db-deployment"
    }

    port {
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
