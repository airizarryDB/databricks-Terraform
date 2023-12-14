## Setting up Terraform

Step 1: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Step 2: [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on local machine

Step 3: Git Clone Repo
  ``` 
    git clone https://github.com/airizarryDB/databricks-Terraform.git
   ``` 
Step 4: Change Directories

  ```
    cd databricks-Terraform/privatelink-byovpc/
   ``` 

Step 5: Set values in template.tfvars file

Using any editor set the values in the template.tfvars file. The descriptions of all the variables are located in the variables.tf file. Once the variables are set you are ready to run Terraform.

Further Documentation for some of the variables:

[databricks_account_id](https://docs.databricks.com/administration-guide/account-settings/index.html#locate-your-account-id)


## Run Terraform

Step 6: Terraform [Init](https://developer.hashicorp.com/terraform/cli/commands/init)

The terraform init command initializes a working directory containing configuration files and installs plugins for required providers.

  ```
    terraform init -var-file="template.tfvars"
  ```

Step 7: Terraform [Plan](https://developer.hashicorp.com/terraform/cli/commands/plan)

The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:

  * Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
  * Compares the current configuration to the prior state and noting any differences.
  * Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

  ```
    terraform plan -var-file="template.tfvars"
  ```

Step 8: Terraform [Apply](https://developer.hashicorp.com/terraform/cli/commands/apply)

The terraform apply command executes the actions proposed in a Terraform plan.

  ```
    terraform apply -var-file="template.tfvars"
  ```
