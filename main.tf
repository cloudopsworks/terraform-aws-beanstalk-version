##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name         = var.version_label
  application  = data.aws_elastic_beanstalk_application.application.name
  description  = "Application ${var.source_name} v${var.source_version} for ${var.namespace} Environment, Config SHA: ${var.config_file_sha}"
  force_delete = false
  bucket       = var.application_versions_bucket
  key          = var.bucket_path

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.extra_tags, {
    Namespace   = var.namespace
    Application = var.source_name
    Version     = var.source_version
    ConfigSHA   = var.config_file_sha
  })
}
