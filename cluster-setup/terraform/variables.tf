variable "location" {
  description = "Azure resource location"
  type        = string
  default     = "France Central"
}

variable "tags" {
  description = "Tags required by Novencia"
  type        = map(any)
  default = {
    owner = "amoalla"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version of AKS cluster"
  type        = string
  default     = "1.22.6"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM Size of the nodes"
  type        = string
  default     = "Standard_B2s"
}
