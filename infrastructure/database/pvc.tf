resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name      = "${var.temporal_db_name}-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.temporal_db_storage
      }
    }
    storage_class_name = var.storage_class_name
  }

}
