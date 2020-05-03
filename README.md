# Prerequisites

To deploy hello-world microservice you need to provision `core-infrastructure` project first. 
See https://github.com/iac-demo/core-infrastructure on how to do it.

Also you need to have AWS credentials for your account.
See https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html on how to set them up.

**Warning**: deploying this project will create AWS resources - you will be charged for their usage.

# Configuration

You need to set the following environment variables:
```
export TF_VAR_aws_region=<your_aws_region>
export TF_VAR_aws_account_id=<your_aws_account_id> 
export TF_VAR_s3_state_bucket=<s3_bucket_name_for_project_state>
```

# Building and publishing your service 
Assuming that you already provisioned your core infrastructure, you need to build and publish a docker image gor your service:

1. `./gradlew build` - build the Java project
2. `./gradlew dockerBuild` - build the docker image
3. `./gradlew dockerPush` - push the docker image to an ECR (created by `core-infrastructure`)


# Provisioning Infrastructure and Deploying
After setting up your configuration, you need to execute the following commands to provision your infrastructure and deploy your project.

## Using Terraform
You will need terraform v0.12.x installed and available on your path.
After you set up your configuration, you need to execute the following commands:

```
# go into a folder with Terraform definitions
cd terraform
# initialize Terraform remote state and plugins
terraform init -input=false -backend-config=bucket=$TF_VAR_s3_state_bucket
# preview changes to be deployed
terraform plan -input=false                 
# deploy infrastructure
terraform apply -input=false -auto-approve  # deploy core infrastructure
```

## Using Gradle plugin (Henka)
Alternatively, you can execute your Terraform commands
through [Henka](https://github.com/roku-oss/henka) Gradle plugin.

It takes care of installing the right version of Terraform and initializing Terraform backends and plugins.

However, it prints out the actual Terraform commands into stdout, so if you're interested, you can inspect
their syntax and try them out directly.

1. `./gradlew terraform -P tfAction="plan -input=false"` - do a dry run and inspect resources to be created/modified.
2. `./gradlew terraform -P tfAction="apply -input=false -auto-approve"` - provision all infrastructure resources.

At this stage you can inspect the AWS console, check out the load balancer's DNS entry and make sure that
the microservice was deployed successfully.

# Cleaning Up

After you're done with the demo, you will want to destroy all resources,
so you don't have to pay for them while you're not using them.

You can do it with the following command:

```./gradlew terraform -P tfAction="destroy -input=false -auto-approve"```
