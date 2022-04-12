##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
resource "random_string" "awscli_output_temp_file_name" {
  keepers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
    #allways_run = "${timestamp()}"
  }
  length  = 16
  special = false
}

resource "local_file" "awscli_results_file" {
  depends_on           = [random_string.awscli_output_temp_file_name]
  filename             = "${path.module}/temp/${random_string.awscli_output_temp_file_name.result}.json"
  directory_permission = "0777"
  file_permission      = "0666"
  content              = ""
}

locals {
  assume_role_arn   = var.sts_assume_role
  role_session_name = "Terraform-ENV-fileupload"
  aws_cli_commands = [
    "s3",
    "cp",
    "${path.root}/.work/${var.release_name}/target/package.zip",
    "s3://${data.aws_s3_bucket.version_bucket.id}/${local.bucket_path}",
    "--quiet",
    "--region",
    "${var.region}"
  ]
  debug_log_filename = ""
  aws_cli_query      = ""

  awscli_query = {
    assume_role_arn    = local.assume_role_arn
    role_session_name  = local.role_session_name
    aws_cli_commands   = join(" ", local.aws_cli_commands)
    aws_cli_query      = local.aws_cli_query
    output_file        = local_file.awscli_results_file.filename
    debug_log_filename = local.debug_log_filename
    aws_region         = var.region
  }
}

resource "null_resource" "awscli_program" {
  depends_on = [
    null_resource.build_package,
    null_resource.release_download_zip,
    null_resource.release_download_java,
    null_resource.release_conf_copy_node,
    null_resource.release_conf_copy,
    local_file.awscli_results_file
    # data.archive_file.build_package
  ]
  triggers = {
    dir_sha1 = local.config_file_sha
    version  = var.source_version
  }

  provisioner "local-exec" {
    command = "echo '${jsonencode(local.awscli_query)}' | ${path.module}/scripts/awsWithAssumeRole.sh"
  }
}
