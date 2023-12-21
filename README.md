## Terraform Configuration Explanation

The Terraform configuration has been divided in 3 main files:

- The `main.tf` file contains the Terraform configuration for this project. This configuration sets up the necessary resources for a Lambda function and an API Gateway. The Lambda function code is stored in an S3 bucket, and the API Gateway is configured to trigger the Lambda function when it receives a request.

- The `outputs.tf` file contains the required cloudformation outputs

- The `variables.tf` file contains the variable needed by terraform to deploy the stack

## Local Deployment Using Task

This project uses [Task](https://taskfile.dev/#/), a task runner / simpler Make alternative written in Go, to automate the deployment process.

### Prerequisites

- Install [Task](https://taskfile.dev/#/installation)
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Configure your AWS credentials:
  - create an .env file and define TF_VAR_aws_access_key, TF_VAR_aws_secret_key env vars based on your AWS credentials as shown in the .env.example file. Those will be used by terraform to populate the matching aws credentials.

### Steps

1. **Initialize Terraform**

    This will download the necessary provider plugins.

    ```bash
    task init
    ```

2. **Deploy the Infrastructure**

    This will apply the Terraform configuration and create the resources defined in it.

    ```bash
    task deploy
    ```

3. **Invoke the API Gateway**

    This will send a request to the API Gateway and print the response.

    ```bash
    task invoke-gateway
    ```

4. **Destroy the Infrastructure**

    When you're done, you can destroy the resources that were created to avoid incurring any further costs.

    ```bash
    task destroy
    ```

5. **One Cmd to rue them all**

    To run 1,2,3 in one cmd, just do:

    ```bash
    task setup
    ```
