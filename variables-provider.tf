##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
variable "region" {
  type        = string
  description = "(Optional) AWS region used by the provider. Default: \"us-east-1\""
  default     = "us-east-1"
}

variable "sts_assume_role" {
  type        = string
  description = "(Required) IAM role ARN assumed to register the application version. Needs elasticbeanstalk:CreateApplicationVersion and read access to the bundle."
}