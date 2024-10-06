//-------------(Auth)---------------///

variable "access_key" {
  description = "Access Key for test IAM user"
  default     = "AKIAYM7POAQ2ZLU7XAMR"
}


variable "secret_key" {
  description = "Secret Key for test IAM user"
  default     = "DdTT8uN70R0f8NjtoSuYZtiNrf2dtFQTkWhuZUVP"
}


variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "key_pair_name" {
  description = "The name of the key pair to use for EC2 instances"
  type        = string
}

//-------------------------------------------////

//---------(VPC-A config)---------------///
variable "vpc_1_cidr" {
  description = "CIDR block for the first VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_1_public_subnet_cidr" {
  description = "CIDR block for the public subnet in VPC 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_1_private_subnet_cidr" {
  description = "CIDR block for the private subnet in VPC 1"
  type        = string
  default     = "10.0.2.0/24"
}

//-------------------------------------------////

//---------(VPC-B config )---------------///

variable "vpc_2_cidr" {
  description = "CIDR block for the second VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "vpc_2_private_subnet_cidr" {
  description = "CIDR block for the private subnet in VPC 2"
  type        = string
  default     = "172.16.1.0/24"
}


//-------------------------------------------////

//-----------(Instance Declaration vARIABLES)---------------///

variable "nginx_instance_type" {
  description = "Instance type for the nginx host"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  default = "ami-0d081196e3df05f4d"
}


variable "private_instance_type" {
  description = "Instance type for the private instances"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH to the nginx host"
  type        = string
  default     = "0.0.0.0/0" # Warning: This allows SSH from anywhere. Restrict this in production.
}

//-------------------------------------------////
//-------------------------------------------////
//-------------------------------------------////

