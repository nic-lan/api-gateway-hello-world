# API Gateway Hello World

## Description

This README and the code is hosted at the private repo [https://github.com/nic-lan/api-gateway-hello-world](https://github.com/nic-lan/api-gateway-hello-world).


> We would like you to deploy a simple "hello world" http app in AWS, using Api Gateway and Lambda.
Now it is up to you to write the code!
For the infrastructure code, use terraform.
For the application code, you can use choose which language to use.
The challenge is to write the code.
If you have an AWS account you can also deploy it, but this is not required!

To perform the exercise Terraform has been used to manage the infra and the deployment.

The repo is devided in 4 main points:

- **main-infra**:
  this is the terreform code which is intended to be run during setup to allow injection in the AWS account of required resources to support terraform S3 backend. This is done to allow cloud persistence of the terraform state of the API Gateway Hello World across rather than local and should be considered as a first attempt to allow team CI. More info on how to setup it at [Setup Main Infra](#setup-main-infra)

- **hello-world**:
  This is the python code for the hello-world lambda. It contains also a minimal test spec suite to be used later in the CI.

- **api-infra**:
  This is the directory containing all the required infra to deploy and maintain the AWS Api Gateway backed up by the hello-wold lambda. It includes minimal resource provisioning to allow `curl` on the endpoint.

- **CI .github/workflows/ci.yaml**
  Bonus Point. This is the github CI workflow and it describes 2 different paths:
  1. PRs: When a PR is created, the CI perform the test, the linting and the packaging of the python code. When those steps are successfull terraform planning is performed.
  2. Pushes to the main branch: Here all the steps at 1) are executed again and eventually terraform resource provisioning is applied.

## Setup Main Infra

This section is intented to explain the end user how to make the initial resource provisiong of the S3 bucket which will be used later in the CI to keep track of the terraform state changes related with the API Gateway.

### Prerequisites

- Install [Task](https://taskfile.dev/#/installation)
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- AWS account
- AWS credentials:
  - create an .env file based on the .env.example file. Place the required AWS Credentials.

#### Note

The credentials should respect the least privilegie to allow the terraform to perform the resource provisioning


### Steps

1. **Setup main Infrastructure**

    This will download the necessary provider plugins  and apply the Terraform configuration to create the resources defined in it.

    ```bash
    task setup -- main-infra
    ```

## Api Gateway Resource Provisioning

It is possible to make the API resource provisioning under full automation by running the CI or manually from console.
The terraform state uses the S3 bucket `terraform-state` originally provisioned by the `main-infra`, so whatever is your favourite approach for the CI, the state won't get out of sync.

### By Running the CI

The CI is a github action, so if you would like to take advantage of fully automation of the resource provisioning and the lambda code updates, the best thing would be to push this code into a github repo of your choice.

#### Requirements

- One github repo to host this code. Otherwise, I could invite you to [https://github.com/nic-lan/api-gateway-hello-world](https://github.com/nic-lan/api-gateway-hello-world)
- Have the AWS credentials saved as `secrets` in the github repo. Please remember that the AWS credentials should respect the "least privilege" to perform the terraform plan/apply on the destination AWS account.

### By running terraform locally

The prerequisites are the same  at [Setup Main Infra](#setup-main-infra).

If your favourite way to see the code in action is to run terraform locally, please run:

```bash
task setup -- api-infra
```

### Invoke The API Gateway

The prerequisites are the same  at [Setup Main Infra](#setup-main-infra).

Once the CI has successfully deployed the API Gateway, you can invoke the end point and received your "Hello World" message.

This will send a request to the API Gateway and print the response

```bash
task invoke-gateway
```

## Notes

There are some alternatives to the current way of performing terraform, for example Terraform Cloud and Atlantis.
Also, the CI topic could be achieved in many other ways. For example, rather than having the deploy happening from the GH action, we could have a AWS CodePipeline being triggered whenever new code gets pushed the github repo main branch. From a security perspective this could be desirable since all the terraform ops would be happening from inside the AWS account.
