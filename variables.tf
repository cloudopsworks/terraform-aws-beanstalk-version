##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
variable "release_name" {
  type = string
}

variable "source_name" {
  type = string
}

variable "source_version" {
  type = string
}

variable "namespace" {
  type        = string
  description = "(required) namespace that determines the environment naming"
}

variable "application_versions_bucket" {
  type        = string
  description = "(Required) Application Versions bucket"
}

variable "bucket_path" {
  type        = string
  description = "(Required) Bucket path to store the application version"
}

variable "beanstalk_application" {
  type        = string
  description = "(Required) Elastic Beanstalk Application Name, should already exist."
}

variable "config_file_sha" {
  type        = string
  description = "(required) SHA of the configuration file"
}

variable "version_label" {
  type        = string
  description = "(required) Version label for the application"
}

variable "extra_tags" {
  type        = map(string)
  description = "(optional) Extra tags to be added to the resources"
  default     = {}
}
