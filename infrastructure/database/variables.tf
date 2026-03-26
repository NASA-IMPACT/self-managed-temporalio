variable "temporal_db_name" {
  description = "temporal db name for temporal"
}


variable "namespace" {
  description = "value of namespace"

}

variable "temporal_db_storage" {
  description = "Allocated storage in GB for temporal db"

}

variable "temporal_visibility_db_name" {
  description = "value of temporal visibility db name for temporal"

}


variable "temporal_db_user" {
  description = "value of temporal db user for temporal"

}

variable "temporal_db_password" {
  description = "value of temporal db password for temporal"

}

variable "storage_class_name" {
  description = "value of storage class name for temporal database"
}

variable "temporal_db_cpu_request" {
    description = "value of temporal db cpu request for temporal"
  
}
variable "temporal_db_memory_request" {
    description = "value of temporal db memory request for temporal"
  
}

variable "temporal_db_memory_limit" {
    description = "value of temporal db memory limit for temporal"
  
}

variable "temporal_db_cpu_limit" {
    description = "value of temporal db cpu limit for temporal"
  
}
