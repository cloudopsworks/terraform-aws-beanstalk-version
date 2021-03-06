##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
  bucket_path      = "${var.release_name}/${var.source_version}/${var.source_name}-${var.source_version}-${var.namespace}-${upper(substr(local.config_file_sha, 0, 10))}.zip"
  config_file_sha  = sha1(join("", [for f in fileset(".", "${path.root}/values/${var.release_name}/**") : filesha1(f)]))
  version_label    = "${var.release_name}-${var.source_version}-${var.namespace}-${upper(substr(local.config_file_sha, 0, 10))}"
  download_java    = length(regexall("(?i:.*java.*|.*corretto.*)", lower(var.solution_stack))) > 0 && !var.force_source_compressed
  download_package = length(regexall("(?i:.*java.*|.*corretto.*)", lower(var.solution_stack))) <= 0 || var.force_source_compressed
  is_tar           = (var.source_compressed_type == "tar")
  is_tarz          = length(regexall("(?i:tar.z|tz)", var.source_compressed_type)) > 0
  is_targz         = length(regexall("(?i:tar.gz|tgz)", var.source_compressed_type)) > 0
  is_tarbz         = length(regexall("(?i:tar.bz|tar.bz2|tbz|tbz2)", var.source_compressed_type)) > 0
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  depends_on = [
    null_resource.awscli_program
  ]
  name         = local.version_label
  application  = data.aws_elastic_beanstalk_application.application.name
  description  = "Application ${var.source_name} v${var.source_version} for ${var.namespace} Environment"
  force_delete = false
  bucket       = data.aws_s3_bucket.version_bucket.id
  key          = local.bucket_path
}

data "aws_s3_bucket" "version_bucket" {
  bucket = var.application_versions_bucket
}

resource "null_resource" "build_package" {
  depends_on = [
    null_resource.release_download,
    null_resource.uncompress_tar,
    null_resource.uncompress_zip,
    null_resource.uncompress_tar_z,
    null_resource.uncompress_tar_bz,
    null_resource.uncompress_tar_gz,
    null_resource.release_download_java,
    null_resource.release_conf_copy_node,
    null_resource.release_conf_copy
  ]
  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "zip -rqy ../target/package.zip ."
    working_dir = "${path.root}/.work/${var.release_name}/build"
  }
}

resource "null_resource" "release_pre" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/.work/${var.release_name}/build/"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/.work/${var.release_name}/target/"
  }
}

resource "null_resource" "release_conf_copy" {
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download_java,
    null_resource.release_download
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "cp -pr ${path.root}/values/${var.release_name}/* ${path.root}/.work/${var.release_name}/build/"
  }

  # EB extensions
  provisioner "local-exec" {
    command = "${path.module}/scripts/check_copy.sh ${path.root}/values/${var.release_name}/.ebextensions ${path.root}/.work/${var.release_name}/build/"
  }

  # EB platform
  provisioner "local-exec" {
    command = "${path.module}/scripts/check_copy.sh  ${path.root}/values/${var.release_name}/.platform ${path.root}/.work/${var.release_name}/build/"
  }


  provisioner "local-exec" {
    command = "echo \"Release: ${var.source_name} v${var.source_version} - Environment: ${var.release_name} / ${var.namespace}\" > .work/${var.release_name}/build/VERSION"
  }
}

resource "null_resource" "release_conf_copy_node" {
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download
  ]
  count = length(regexall("(?i:.*node.*)", lower(var.solution_stack))) > 0 ? 1 : 0

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
  }

  provisioner "local-exec" {
    command = "cp -pr ${path.root}/values/${var.release_name}/.env ${path.root}/.work/${var.release_name}/build/"
  }
}

resource "null_resource" "release_download_java" {
  count = local.download_java ? 1 : 0
  depends_on = [
    null_resource.release_pre
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/github-asset.sh ${var.repository_owner} ${var.source_name} v${var.source_version} ${var.source_name}-${var.source_version}.jar .work/${var.release_name}/build/app.jar"
  }
}

resource "null_resource" "release_download" {
  count = local.download_package ? 1 : 0
  depends_on = [
    null_resource.release_pre
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/github-asset.sh ${var.repository_owner} ${var.source_name} v${var.source_version} ${var.source_name}-${var.source_version}.${var.source_compressed_type} ${path.root}/.work/${var.release_name}/build/source-app.zip"
  }
}

resource "null_resource" "uncompress_zip" {
  count = local.download_package && (var.source_compressed_type == "zip") ? 1 : 0
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "unzip -qoK source-app.zip"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.zip"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }
}

resource "null_resource" "uncompress_tar" {
  count = local.download_package && local.is_tar ? 1 : 0
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "tar -xf source-app.tar"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.tar"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }
}

resource "null_resource" "uncompress_tar_z" {
  count = (local.download_package && local.is_tarz) ? 1 : 0
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "tar -Zxf source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }
}

resource "null_resource" "uncompress_tar_gz" {
  count = (local.download_package && local.is_targz) ? 1 : 0
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "tar -zxf source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }
}

resource "null_resource" "uncompress_tar_bz" {
  count = (local.download_package && local.is_tarbz) ? 1 : 0
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "bzip2 -d -c source-app.${var.source_compressed_type} | tar -xf -"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/build/"
  }
}