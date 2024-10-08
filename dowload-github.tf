##
# (c) 2023 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
resource "null_resource" "release_download_gh_java" {
  count = var.github_package && var.package_type == "MAVEN" ? 1 : 0
  depends_on = [
    null_resource.release_pre
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/gh-download-java.sh ${var.repository_owner} ${var.source_name} ${var.source_version} ${var.package_name} ${var.package_type} ${local.tmp_dir}/${var.release_name}/${local.build_folder}/app.jar"
  }

  provisioner "local-exec" {
    command = "chmod +x ${local.tmp_dir}/${var.release_name}/${local.build_folder}/app.jar"
  }
}

resource "null_resource" "release_download_gh_node" {
  count = var.github_package && var.package_type == "NPM" ? 1 : 0
  depends_on = [
    null_resource.release_pre
  ]

  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/gh-download-npm.sh ${var.repository_owner} ${var.source_name} ${var.source_version} ${var.package_name} ${var.package_type} ${local.tmp_dir}/${var.release_name}/${local.build_folder}/source-app.tgz"
  }

  # Unpack the tarball strip the top level directory: package/
  provisioner "local-exec" {
    command     = "tar --strip-components=1 -zxf source-app.tgz"
    working_dir = "${local.tmp_dir}/${var.release_name}/${local.build_folder}/"
  }

  provisioner "local-exec" {
    command     = "rm -f source-app.tgz"
    working_dir = "${local.tmp_dir}/${var.release_name}/${local.build_folder}/"
  }
}