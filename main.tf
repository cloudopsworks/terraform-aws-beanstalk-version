##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
  root_path       = startswith(var.config_source_folder, "/") ? "" : "${path.root}/"
  config_file_sha = upper(substr(split(" ", file("${local.root_path}${var.config_hash_file}"))[0], 0, 10))
  bucket_path     = "${var.release_name}/${var.source_version}/${var.source_name}-${var.source_version}-${var.namespace}-${local.config_file_sha}.zip"
  version_label   = "${var.release_name}-${var.source_version}-${var.namespace}-${local.config_file_sha}"
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name         = local.version_label
  application  = data.aws_elastic_beanstalk_application.application.name
  description  = "Application ${var.source_name} v${var.source_version} for ${var.namespace} Environment, Config SHA: ${local.config_file_sha}"
  force_delete = false
  bucket       = var.application_versions_bucket
  key          = local.bucket_path

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.extra_tags, {
    Namespace   = var.namespace
    Application = var.source_name
    Version     = var.source_version
    ConfigSHA   = local.config_file_sha
  })
}
