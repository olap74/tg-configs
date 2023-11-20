# Variables storages concept

This repository contains a Terragrunt configuration to demonstrate how S3 bucket or Parameters store can be user for storing variables and how these variables can be used with Terragrunt. 

> [!IMPORTANT]
> In case if you decided to use this way of variables management you will need a separate process for adding variables to SSM or S3 to avoid any manual updates. Every update should be reviewed and approved before getting to AWS. 

The main idea is to store variables in AWS and use the same resources for multiple repos.  This allows to follow "keep everything in one place" and "DRY" principals. 

## AWS Resources

There are two AWS resources are being used: 

- SSM Parameter
- S3 Bucket File

Both of these parameters are JSON formatted variables. To convert HCL variables to JSON [HCL2JSON](https://github.com/tmccombs/hcl2json) can be used.

Terragrunt gets variables from AWS resources using built-in function [run_cmd()](https://terragrunt.gruntwork.io/docs/reference/built-in-functions/#run_cmd)

But `run_cmd()` function returns plain text and this content is being converted with another built-in function `jsondecode()`

The content is being taken using AWS Cli commands:

For SSM: 
```
aws ssm get-parameter --profile PROFILE --region REGION --name SSM_PARAM_NAME --with-decryption --query Parameter.Value --output text
```
For S3 Bucket file:
```
aws s3 cp --profile PROFILE --region REGION S3_FILE_NAME -
```
Where,
- `PROFILE` - AWS Profile name
- `REGION` - AWS Region where variables are being stored
- `SSM_PARAM_NAME` - SSM Parameter name
- `S3_FILE_NAME` - File name including S3 bucket name (`s3://bucket-name/s3-vars.json`)

All parameters are being provided with Terragrunt values. The `terragrunt.hcl` file for partucular module looks like: 

```
include {
  path =  find_in_parent_folders()
}

locals {
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    region_vars =  read_terragrunt_config(find_in_parent_folders("region.hcl"))
    ssm_vars =  jsondecode(run_cmd(
        "aws", "ssm", "get-parameter",
        "--profile", "${local.account_vars.locals.aws_profile}",
        "--region", "${local.account_vars.locals.main_region}",
        "--name", "${local.account_vars.locals.common_params}",
        "--with-decryption",
        "--query", "Parameter.Value", "--output", "text"
    ))

    s3_vars =  jsondecode(run_cmd(
        "aws", "s3", "cp",
        "--profile", "${local.account_vars.locals.aws_profile}",
        "--region", "${local.account_vars.locals.main_region}",
        "${local.account_vars.locals.params_file}",
        "-"
    ))
}

terraform {
    source =  "${get_parent_terragrunt_dir()}/../../modules//test_module"
}

inputs =  merge(
    local.account_vars.locals,
    local.region_vars.locals,
    local.ssm_vars.locals,
    local.s3_vars.locals
)
```

### Variables example

Example variables files you can find in the `vars_example` directory of this repo. This directory contains three files:

- `s3-vars.hcl`
- `s3-vars.json`
- `ssm-vars.hcl`

All `*.hcl` files can be converted to JSON format using [hcl2json](https://github.com/tmccombs/hcl2json) utility. JSON format is required for this solution.  
