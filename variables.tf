##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
variable "release_name" {
  type        = string
  description = "(Required) Release name of the delivery pipeline run that produced the application bundle. e.g. \"payments-api-1.4.2\""
}

variable "source_name" {
  type        = string
  description = "(Required) Source application name, emitted as the `Application` tag and used in the version description. e.g. \"payments-api\""
}

variable "source_version" {
  type        = string
  description = "(Required) Source application version, emitted as the `Version` tag and used in the version description. e.g. \"1.4.2\""
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
