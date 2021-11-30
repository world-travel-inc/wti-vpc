
variable "project" {
  type        = string
  description = "Project name"
  default = "wti"
}

variable "region" {
  type        = string
  description = "Azure region"
  default     = "us-east-2"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR (set in 'terraform.tfvars')"
}

variable "subnet_public_cidr_block" {
  type        = string
  description = "Public subnet CIDR (set in 'terraform.tfvars')"
}

variable "subnet_private_cidr_block" {
  type        = string
  description = "Private subnet CIDR (set in 'terraform.tfvars')"
}

variable "facing-internal-or-external" {
  type        = string
  description = "Will this VPC be the internal or external facing? answer either 'int' or 'ext'."
  validation {
    condition = var.facing-internal-or-external == "int" || var.facing-internal-or-external == "ext"
    error_message = "Only \"int\" or \"ext\" are accepted for this variable."
  }
}

variable "dept" {
  type        = string
  description = "The department/cost-center that these components belong to."
  default     = "DEV"
}

variable "env" {
  type        = string
  description = "The environment that this conponent is tied to. Answer either 'dev' or 'stage' or 'prod'."
  validation {
    condition = var.env == "dev" || var.env == "stage" || var.env == "prod"
    error_message = "Only \"dev\" or \"stage\" or \"prod\" are accepted for this variable."
  }
}
