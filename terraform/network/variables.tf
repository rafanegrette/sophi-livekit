# General variables
variable "compartment_id" {
  description = "The OCID of the compartment"
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags for resources"
  type        = map(string)
  default     = {}
}

# VCN variables
variable "vcn_name" {
  description = "Name of the VCN"
  type        = string
  default     = "livekit-vcn"
}

variable "vcn_cidrs" {
  description = "List of CIDR blocks for the VCN"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN"
  type        = string
  default     = "livekitvcn"
}

# Gateway variables
variable "create_internet_gateway" {
  description = "Create an internet gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Create a NAT gateway"
  type        = bool
  default     = true
}

variable "create_service_gateway" {
  description = "Create a service gateway"
  type        = bool
  default     = true
}

# Security List variables
variable "public_security_list_name" {
  description = "Name of the public security list"
  type        = string
  default     = "security-list-for-public-subnet"
}

variable "private_security_list_name" {
  description = "Name of the private security list"
  type        = string
  default     = "security-list-for-private-subnet"
}

# Subnet variables
variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = "public-subnet"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = "private-livekit-subnet"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}