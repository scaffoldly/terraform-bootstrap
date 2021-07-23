# Scaffoldly Terraform Bootstrap Project

[![Maintained by Scaffoldly](https://img.shields.io/badge/maintained%20by-scaffoldly-blueviolet)](https://github.com/scaffoldly)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/scaffoldly/terraform-scaffoldly-bootstrap)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.15.0-blue.svg)

# About

Used in tandem with the [Bootstrap Template](https://github.com/scaffoldly/bootstrap-template) during Scaffoldly Bootstrapping.

See the [Docs](https://docs.scaffold.ly) and [Scaffoldly Start](https://start.scaffold.ly) to use this module.

# Usage

See [scaffoldly/bootstrap-template](https://github.com/scaffoldly/bootstrap-template/blob/main/main.tf)

# Examples

- [Scaffoldly Demo](https://github.com/scaffoldly-demo/scaffoldly-bootstrap)
- [Futz.dev](https://github.com/futz-dev/scaffoldly-bootstrap) (Scaffoldly Upstream Development)

# Terraform Docs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.33.0 |
| <a name="requirement_dnsimple"></a> [dnsimple](#requirement\_dnsimple) | 0.5.1 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.1.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 4.9.4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.1.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | 2.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_api_gateway"></a> [aws\_api\_gateway](#module\_aws\_api\_gateway) | scaffoldly/api-gateway/aws | 0.15.1 |
| <a name="module_aws_logging"></a> [aws\_logging](#module\_aws\_logging) | scaffoldly/logging/aws | 0.15.2 |
| <a name="module_aws_organization"></a> [aws\_organization](#module\_aws\_organization) | scaffoldly/organization/aws | 0.15.9 |
| <a name="module_dns"></a> [dns](#module\_dns) | scaffoldly/dns/aws | 0.15.3 |
| <a name="module_email"></a> [email](#module\_email) | scaffoldly/email/aws | 0.15.3 |
| <a name="module_github_config_files_public_websites"></a> [github\_config\_files\_public\_websites](#module\_github\_config\_files\_public\_websites) | scaffoldly/config-files/github | 0.15.1 |
| <a name="module_github_config_files_serverless_apis"></a> [github\_config\_files\_serverless\_apis](#module\_github\_config\_files\_serverless\_apis) | scaffoldly/config-files/github | 0.15.1 |
| <a name="module_public_website"></a> [public\_website](#module\_public\_website) | scaffoldly/public-website/aws | 0.15.1 |
| <a name="module_serverless_api"></a> [serverless\_api](#module\_serverless\_api) | scaffoldly/serverless-api/aws | 0.15.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_service"></a> [auth\_service](#input\_auth\_service) | n/a | `bool` | `true` | no |
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | n/a | `list(string)` | <pre>[<br>  "us-east-1"<br>]</pre> | no |
| <a name="input_dns_provider"></a> [dns\_provider](#input\_dns\_provider) | n/a | `string` | `"aws"` | no |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | n/a | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | n/a | `string` | n/a | yes |
| <a name="input_public_websites"></a> [public\_websites](#input\_public\_websites) | TODO: Env Vars | <pre>map(<br>    object({<br>      template  = string<br>      repo_name = optional(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_root_email"></a> [root\_email](#input\_root\_email) | n/a | `string` | n/a | yes |
| <a name="input_serverless_api_subdomain"></a> [serverless\_api\_subdomain](#input\_serverless\_api\_subdomain) | n/a | `string` | `"sly"` | no |
| <a name="input_serverless_apis"></a> [serverless\_apis](#input\_serverless\_apis) | TODO: Env Vars | <pre>map(<br>    object({<br>      template       = string<br>      repo_name      = optional(string)<br>      decommissioned = optional(bool)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_shared_env_vars"></a> [shared\_env\_vars](#input\_shared\_env\_vars) | n/a | `map(string)` | `{}` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | n/a | <pre>map(<br>    object({<br>      domain           = string<br>      subdomain_suffix = optional(string)<br>      env_vars         = optional(map(string))<br>    })<br>  )</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_stage_domains"></a> [stage\_domains](#output\_stage\_domains) | n/a |
<!-- END_TF_DOCS -->

# Contributing

We'd love your contributions. Start [here](https://docs.scaffold.ly/contributing)

# Copyrights

Copyright © 2021 Scaffoldly LLC
