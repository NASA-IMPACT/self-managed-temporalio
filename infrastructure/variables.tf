variable "namespace" {
  description = "temporalio namespace"
  default     = "temporal"
}

variable "temporal_chart_version" {
  description = "value of temporal chart version"
  default     = "1.0.0-rc.1"
}

variable "timeout_seconds" {
  description = "value of timeout seconds"
  default     = "900"
}


variable "db_plugin_name" {
  description = "value of db plugin name for temporal"
  default     = "postgres12"

}

variable "db_driver_name" {
  description = "value of db driver name for temporal"
  default     = "postgres12"

}



variable "temporal_db_name" {
  description = "value of temporal db name for temporal"
  default     = "temporal"

}

variable "temporal_db_host" {
  description = "value of temporal db host for temporal"
  default     = "localhost"

}

variable "temporal_db_port" {
  description = "temporal db port"
  default     = "5432"

}

variable "temporal_db_user" {
  description = "value of temporal db user for temporal"
  default     = "temporal"

}

variable "temporal_db_password" {
  description = "value of temporal db password for temporal"
  default     = "temporal1234"
  sensitive   = true

}


variable "temporal_visibility_db_name" {
  description = "value of temporal visibility db name for temporal"
  default     = "visibility"

}


variable "storage_class_name" {
  description = "value of storage class name for temporal database"
  default     = "standard"
}



variable "temporal_db_cpu_request" {
    description = "value of temporal db cpu request for temporal"
    default = "250m"
  
}
variable "temporal_db_memory_request" {
    description = "value of temporal db memory request for temporal"
    default = "256Mi"
  
}

variable "temporal_db_memory_limit" {
    description = "value of temporal db memory limit for temporal"
    default = "500m"
  
}

variable "temporal_db_cpu_limit" {
    description = "value of temporal db cpu limit for temporal"
    default = "512Mi"
  
}

variable "use_traefik_ingress" {
    description = "Wither to use traefik ingress controller or not"
    default = true
  
}
variable "domain_name" {
  type = string
}
