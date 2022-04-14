## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elastic_beanstalk_application_version.app_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application_version) | resource |
| [local_file.awscli_results_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.awscli_program](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.build_package](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.release_conf_copy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.release_conf_copy_node](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.release_download](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.release_download_java](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.release_pre](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.uncompress_tar](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.uncompress_tar_bz](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.uncompress_tar_gz](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.uncompress_tar_z](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.uncompress_zip](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.awscli_output_temp_file_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elastic_beanstalk_application.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elastic_beanstalk_application) | data source |
| [aws_s3_bucket.version_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_versions_bucket"></a> [application\_versions\_bucket](#input\_application\_versions\_bucket) | (Required) Application Versions bucket | `string` | n/a | yes |
| <a name="input_beanstalk_application"></a> [beanstalk\_application](#input\_beanstalk\_application) | (Required) Elastic Beanstalk Application Name, should already exist. | `string` | n/a | yes |
| <a name="input_force_source_compressed"></a> [force\_source\_compressed](#input\_force\_source\_compressed) | (Optional) Forces that source file should be downloaded as zip file or tar file | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (required) namespace that determines the environment naming | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | # (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/ On GitHub: https://github.com/cloudopsworks Distributed Under Apache v2.0 License | `string` | `"us-east-1"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | # (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/ On GitHub: https://github.com/cloudopsworks Distributed Under Apache v2.0 License | `string` | n/a | yes |
| <a name="input_repository_owner"></a> [repository\_owner](#input\_repository\_owner) | (required) Repository onwer/team | `string` | n/a | yes |
| <a name="input_repository_url"></a> [repository\_url](#input\_repository\_url) | (optional) repository url to pull releases. | `string` | `"https://github.com"` | no |
| <a name="input_solution_stack"></a> [solution\_stack](#input\_solution\_stack) | (required) Specify solution stack for Elastic Beanstalk<br>Solution stack is one of:<br>  java      = \"^64bit Amazon Linux 2 (.*) Corretto 8(.*)$\"<br>  java11    = \"^64bit Amazon Linux 2 (.*) Corretto 11(.*)$\"<br>  node      = \"^64bit Amazon Linux 2 (.*) Node.js 12(.*)$\"<br>  node14    = \"^64bit Amazon Linux 2 (.*) Node.js 14(.*)$\"<br>  go        = \"^64bit Amazon Linux 2 (.*) Go (.*)$\"<br>  docker    = \"^64bit Amazon Linux 2 (.*) Docker (.*)$\"<br>  docker-m  = \"^64bit Amazon Linux 2 (.*) Multi-container Docker (.*)$\"<br>  java-amz1 = \"^64bit Amazon Linux (.*)$ running Java 8(.*)$\"<br>  node-amz1 = \"^64bit Amazon Linux (.*)$ running Node.js(.*)$\" | `string` | `"java"` | no |
| <a name="input_source_compressed_type"></a> [source\_compressed\_type](#input\_source\_compressed\_type) | (Optional) Indicates the type of the source package to proceed with its de-compression. | `string` | `"zip"` | no |
| <a name="input_source_name"></a> [source\_name](#input\_source\_name) | n/a | `string` | n/a | yes |
| <a name="input_source_version"></a> [source\_version](#input\_source\_version) | n/a | `string` | n/a | yes |
| <a name="input_sts_assume_role"></a> [sts\_assume\_role](#input\_sts\_assume\_role) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_version_label"></a> [application\_version\_label](#output\_application\_version\_label) | n/a |
| <a name="output_application_version_path"></a> [application\_version\_path](#output\_application\_version\_path) | n/a |
