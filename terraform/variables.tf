variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_host" {
  description = "IP o Hostname de la Base de Datos Existente"
  type        = string
  default     = "10.0.1.100" 
}
variable "ecr_frontend_url" {
  type = string
  default = "801716241958.dkr.ecr.us-east-1.amazonaws.com/tienda-frontend:latest"
}

variable "ecr_ventas_url" {
  type = string
  default = "801716241958.dkr.ecr.us-east-1.amazonaws.com/tienda-backend:ventas-latest"
}

variable "ecr_despachos_url" {
  type = string
  default = "801716241958.dkr.ecr.us-east-1.amazonaws.com/tienda-backend:despachos-latest"
}
