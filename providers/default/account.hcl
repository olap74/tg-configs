locals {
    aws_profile = "default"
    main_region = "eu-central-1"
    common_params = "/devops/terragrunt/variables/common"
    params_file = "s3://terragrunt-vars-test/s3-vars.json"
}
