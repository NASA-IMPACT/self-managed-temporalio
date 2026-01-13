# Persistent Volume Claim for PostgreSQL data storage
# Ensures database persistence across pod restarts and node failures
resource "kubernetes_persistent_volume_claim_v1" "temporal_db_pvc" {
  metadata {
    name      = "${var.temporal_db_name}-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"] # Single node access for PostgreSQL

    resources {
      requests = {
        storage = var.temporal_db_storage
      }
    }
    storage_class_name = var.storage_class_name
  }
}
