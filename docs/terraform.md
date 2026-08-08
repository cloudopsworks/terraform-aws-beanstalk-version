## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_elastic_beanstalk_application_version.app_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application_version) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elastic_beanstalk_application.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elastic_beanstalk_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_versions_bucket"></a> [application\_versions\_bucket](#input\_application\_versions\_bucket) | (Required) Application Versions bucket | `string` | n/a | yes |
| <a name="input_beanstalk_application"></a> [beanstalk\_application](#input\_beanstalk\_application) | (Required) Elastic Beanstalk Application Name, should already exist. | `string` | n/a | yes |
| <a name="input_bucket_path"></a> [bucket\_path](#input\_bucket\_path) | (Required) Bucket path to store the application version | `string` | n/a | yes |
| <a name="input_config_file_sha"></a> [config\_file\_sha](#input\_config\_file\_sha) | (required) SHA of the configuration file | `string` | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | (optional) Extra tags to be added to the resources | `map(string)` | `{}` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (required) namespace that determines the environment naming | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region used by the provider. Default: "us-east-1" | `string` | `"us-east-1"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | (Required) Release name of the delivery pipeline run that produced the application bundle. e.g. "payments-api-1.4.2" | `string` | n/a | yes |
| <a name="input_source_name"></a> [source\_name](#input\_source\_name) | (Required) Source application name, emitted as the `Application` tag and used in the version description. e.g. "payments-api" | `string` | n/a | yes |
| <a name="input_source_version"></a> [source\_version](#input\_source\_version) | (Required) Source application version, emitted as the `Version` tag and used in the version description. e.g. "1.4.2" | `string` | n/a | yes |
| <a name="input_sts_assume_role"></a> [sts\_assume\_role](#input\_sts\_assume\_role) | (Required) IAM role ARN assumed to register the application version. Needs elasticbeanstalk:CreateApplicationVersion and read access to the bundle. | `string` | n/a | yes |
| <a name="input_version_label"></a> [version\_label](#input\_version\_label) | (required) Version label for the application | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_version_label"></a> [application\_version\_label](#output\_application\_version\_label) | Version label of the registered Elastic Beanstalk application version. Feed this into the Elastic Beanstalk environment to deploy the release. |
| <a name="output_application_version_path"></a> [application\_version\_path](#output\_application\_version\_path) | S3 key of the application bundle registered as this version, relative to the application versions bucket. |
