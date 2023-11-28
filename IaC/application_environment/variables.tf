variable "prefix" {
  default = "devops_challenge"
}

variable "app_name" {
  default = "devops-challenge"
}

variable "app_logs_retention_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}