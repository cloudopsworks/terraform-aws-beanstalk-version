##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
output "application_version_label" {
  value = aws_elastic_beanstalk_application_version.app_version.name
}

output "application_version_path" {
  value = local.bucket_path
}