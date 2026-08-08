##
# (c) 2022 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
output "application_version_label" {
  description = "Version label of the registered Elastic Beanstalk application version. Feed this into the Elastic Beanstalk environment to deploy the release."
  value       = aws_elastic_beanstalk_application_version.app_version.name
}

output "application_version_path" {
  description = "S3 key of the application bundle registered as this version, relative to the application versions bucket."
  value       = var.bucket_path
}
