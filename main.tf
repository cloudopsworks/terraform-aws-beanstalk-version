##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
locals {
  #config_file_sha  = sha1(join("", [for f in fileset(".", "${path.root}/${var.config_source_folder}/**") : filesha1(f)]))
  config_file_sha  = upper(substr(split(" ", file("${path.root}/${var.config_hash_file}"))[0], 0, 10))
  bucket_path      = var.bluegreen_identifier == "" ? "${var.release_name}/${var.source_version}/${var.source_name}-${var.source_version}-${var.namespace}-${local.config_file_sha}.zip" : "${var.release_name}/${var.source_version}/${var.source_name}-${var.source_version}-${var.namespace}-${local.config_file_sha}-${var.bluegreen_identifier}.zip"
  version_label    = var.bluegreen_identifier == "" ? "${var.release_name}-${var.source_version}-${var.namespace}-${local.config_file_sha}" : "${var.release_name}-${var.source_version}-${var.namespace}-${local.config_file_sha}-${var.bluegreen_identifier}"
  download_java    = length(regexall("(?i:.*java.*|.*corretto.*)", lower(var.solution_stack))) > 0 && !var.force_source_compressed
  download_package = length(regexall("(?i:.*java.*|.*corretto.*)", lower(var.solution_stack))) <= 0 || var.force_source_compressed
  is_tar           = (var.source_compressed_type == "tar")
  is_tarz          = length(regexall("(?i:tar.z|tz)", var.source_compressed_type)) > 0
  is_targz         = length(regexall("(?i:tar.gz|tgz)", var.source_compressed_type)) > 0
  is_tarbz         = length(regexall("(?i:tar.bz|tar.bz2|tbz|tbz2)", var.source_compressed_type)) > 0
  build_folder     = var.bluegreen_identifier == "" ? "build" : "build-${var.bluegreen_identifier}"
  target_folder    = var.bluegreen_identifier == "" ? "target" : "target-${var.bluegreen_identifier}"
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  depends_on = [
    null_resource.awscli_program
  ]

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

resource "null_resource" "build_package" {
  depends_on = [
    null_resource.release_download,
    null_resource.uncompress_tar,
    null_resource.uncompress_zip,
    null_resource.uncompress_tar_z,
    null_resource.uncompress_tar_bz,
    null_resource.uncompress_tar_gz,
    null_resource.release_download_java,
    null_resource.release_download_gh_java,
    null_resource.release_download_gh_node,
    null_resource.release_conf_copy_node,
    null_resource.release_conf_copy,
    null_resource.release_extra_build
  ]
  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command     = "zip -rqy ../${local.target_folder}/package.zip ."
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}"
  }
}

resource "null_resource" "release_pre" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/.work/${var.release_name}/${local.target_folder}/"
  }
}

resource "null_resource" "release_conf_copy" {
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download_java,
    null_resource.release_download,
    null_resource.release_download_gh_node,
    null_resource.release_download_gh_java,
    null_resource.uncompress_zip,
    null_resource.uncompress_tar,
    null_resource.uncompress_tar_bz,
    null_resource.uncompress_tar_gz,
    null_resource.uncompress_tar_z,
    null_resource.release_conf_copy_node,
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "cp -pfr ${path.root}/${var.config_source_folder}/. ${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  # EB extensions
  provisioner "local-exec" {
    command = "${path.module}/scripts/check_copy.sh ${path.root}/${var.config_source_folder}/.ebextensions ${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  # EB platform
  provisioner "local-exec" {
    command = "${path.module}/scripts/check_copy.sh  ${path.root}/${var.config_source_folder}/.platform ${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }


  provisioner "local-exec" {
    command = "echo \"Release: ${var.source_name} v${var.source_version} - Environment: ${var.release_name} / ${var.namespace}\" > .work/${var.release_name}/${local.build_folder}/VERSION"
  }
}

resource "null_resource" "release_conf_copy_node" {
  depends_on = [
    null_resource.release_pre,
    null_resource.release_download,
    null_resource.release_download_gh_node,
    null_resource.uncompress_zip,
    null_resource.uncompress_tar,
    null_resource.uncompress_tar_bz,
    null_resource.uncompress_tar_gz,
    null_resource.uncompress_tar_z,
  ]
  count = length(regexall("(?i:.*node.*)", lower(var.solution_stack))) > 0 ? 1 : 0

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
  }

  provisioner "local-exec" {
    command = "cp -pr ${path.root}/${var.config_source_folder}/.env ${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}

resource "null_resource" "release_download_java" {
  count = local.download_java && !var.github_package ? 1 : 0
  depends_on = [
    null_resource.release_pre
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/github-asset.sh ${var.repository_owner} ${var.source_name} v${var.source_version} ${var.source_name}-${var.source_version}.jar .work/${var.release_name}/${local.build_folder}/app.jar"
  }

  provisioner "local-exec" {
    command = "chmod +x .work/${var.release_name}/${local.build_folder}/app.jar"
  }
}

resource "null_resource" "release_download" {
  count = local.download_package && !var.github_package ? 1 : 0
  depends_on = [
    null_resource.release_pre
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/github-asset.sh ${var.repository_owner} ${var.source_name} v${var.source_version} ${var.source_name}-${var.source_version}.${var.source_compressed_type} ${path.root}/.work/${var.release_name}/${local.build_folder}/source-app.zip"
  }
}

resource "null_resource" "uncompress_zip" {
  count = local.download_package && !var.github_package && (var.source_compressed_type == "zip") ? 1 : 0
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
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.zip"
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}

resource "null_resource" "uncompress_tar" {
  count = local.download_package && local.is_tar && !var.github_package ? 1 : 0
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
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.tar"
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}

resource "null_resource" "uncompress_tar_z" {
  count = (local.download_package && local.is_tarz && !var.github_package) ? 1 : 0
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
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}

resource "null_resource" "uncompress_tar_gz" {
  count = (local.download_package && local.is_targz && !var.github_package) ? 1 : 0
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
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}

resource "null_resource" "uncompress_tar_bz" {
  count = (local.download_package && local.is_tarbz && !var.github_package) ? 1 : 0
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
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.${var.source_compressed_type}"
    working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}

resource "null_resource" "release_extra_build" {
  count = var.extra_run_command != "" ? 1 : 0
  depends_on = [
    null_resource.release_download,
    null_resource.uncompress_tar,
    null_resource.uncompress_zip,
    null_resource.uncompress_tar_z,
    null_resource.uncompress_tar_bz,
    null_resource.uncompress_tar_gz,
    null_resource.release_download_java,
    null_resource.release_download_gh_java,
    null_resource.release_download_gh_node,
    null_resource.release_conf_copy_node,
    null_resource.release_conf_copy,
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
      command     = var.extra_run_command
      working_dir = "${path.root}/.work/${var.release_name}/${local.build_folder}/"
  }
}