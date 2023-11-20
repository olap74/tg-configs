variable "ssm_variable" {
  type = string
}

variable "ssm_array" {
  type = list(string)
}

variable "s3_variable" {
  type = string
}

variable "s3_array" {
  type = list(string)
}

output "ssm_variable" {
  value = var.ssm_variable
}

output "ssm_array" {
  value = var.ssm_array
}

output "s3_variable" {
  value = var.s3_variable
}

output "s3_array" {
  value = var.s3_array
}
