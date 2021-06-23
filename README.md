# Scaffoldly Terraform Bootstrap Project

[![Maintained by Scaffoldly](https://img.shields.io/badge/maintained%20by-scaffold.ly-blueviolet)](https://scaffold.ly)
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

# What Gets Created?

## In the `aws_organization` module

- An AWS Sub-Organization (Root Account)

## In the `aws_logging` module

- Account Alias
- CloudTrail Logs Bucket + KMS Keys for Encrypted Storage
- CloudFront Logs Bucket + KMS Keys for Encrypted Storage

## In the `dns` module

- A Route53 Delegation Set (Deprecated)
- For each stage in `stages`
  - ACM Certificates
  - ACM Verification Records (Root Account)
  - MX Record for SES (Root Account)

## In the `email` module

- Primary SES Rule Set
- For each stage in `stages`
  - Email Verification of the `ROOT_EMAIL`
  - Domain Verification for the Stage Domain
  - DKIM
  - `MAIL_FROM`
  - Configuration Set
  - SNS Topic for Email Events ("send", "reject", "bounce", "complaint", "delivery", "open", "click", "renderingFailure")
  - `MAIL_FROM` MX Record (Root Account)
  - `SPF` Record (Root Account)
  - `DKIM` Record (Root Account)
  - `no-reply@` Bounce Action

## In the `aws_api_gateway` module

- API Gateway IAM role to publish/create CloudWatch Logs
- API Gateway Account
- For each stage in `stages`
  - API Gateway Domain Name
  - Domain Name CNAME Record (Root Account)

## In the `serverless_api` module

- For each `serverless_api`
  - A GitHub repository
    - Based on the private template
    - Private + Vulnerability Alerts + Delete Branch On Merge + Archive On Deletion
    - Disabled: Downloads, Issues, Projects, Wiki
  - CloudFormation IAM User (Required by serverless)
    - Full access to stacks with same name as GitHub Repository
    - Validate any Stack
    - Create S3 Buckets
    - Modify API Gateway
    - Create CloudWatch Logs
    - Add CloudWatch Event Rules
    - Create lambda functions with the same name as the GitHub Repository
    - Add Lambda Event Source Mappings
    - Create/Update/Delete DynamoDB Tables
    - Manage X-Ray
    - Access Key and Secret Key
- For each stage in `stages`
  - REST API
    - CloudWatch Log Group
    - API Gateway `/health` endpoint
    - API Gateway Initial Deployment (for `/health` endpoint)
    - API Gateway Logging
    - API Gateway Path Mapping
  - Secrets
    - GitHub Repository Secrets
      - AWS Partition, Account ID, Access Key, Secret Key, REST API Id, REST API Root Resource Id
    - AWS Secrets Manager Empty Secret

## In the `public_website` module

- A GitHub repository
  - Based on the private template
  - Private + Vulnerability Alerts + Delete Branch On Merge + Archive On Deletion
  - Disabled: Downloads, Issues, Projects, Wiki
- For each `public_website`
  - For each stage in `stages`
    - A Secured, Versioned, S3 Bucket
    - A CloudFront Access Identity
    - A CloudFront Distribution
    - IAM Roles to Publish to S3 Bucket + Create Cache Invalidations
    - Access Key and Secret Key
    - GitHub Repository Secrets
      - AWS Partition, Account ID, Access Key, Secret Key, REST API Id, REST API Root Resource Id
    - CNAME to Distribution (Root Account)

## In the `github_config_files_serverless_apis` and `github_config_files_public_websites` module

- For each `serverless_api` and `public_website`
  - For each stage in `stages`
    - Create/Update `.scaffoldly/${stage}/service-urls.json`
    - Create/Update `.scaffoldly/${stage}/env-vars.json` and `.env` files

# Contributing

We'd love your contributions. Start [here](https://docs.scaffold.ly/contributing)

# Copyrights

Copyright © 2021 Scaffoldly LLC
