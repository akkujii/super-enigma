# Playground application for GitHub Actions Workflows

This repository is a playground to study Continuous Delivery using GitHub Actions. The main goal is to implement a deployment pipeline listening the main branch to handle automated build and deployments to multiple environments.

The repository contains a very simple static HTML page to Azure Static Web Apps and the necessary GitHub Actions Workflows to deploy the app. The application which is a HTML document is parametrized with commit sha during the build time so it's clear from which commit this application has been built. This is handy when application is deployed to multiple environments.

The repository contains the following GitHub Actions Workflows:

- `build.yml` which creates the HTML document (single deployable artifact) parametrized with commit sha and uploads it to workflow artifacts
- `deploy.yml` which deploys the static web app to Azure using corresponding GitHub Deployment Environment.
- `main.yml` which is the workflow for main branch handling the artifact build using `build.yml` and deploying it to target enviroments using `deploy.yml`
- `manual-deployment.yml` which enables the deployment of the artifact of the specified build to the designated target environment. This workflow is targetted to support exploratory testing where specific build can be deployed "with push of a button".

## Infrastructure deployment

Required tooling:

- terraform cli
- Azure cli

The deployment uses local state.

```sh

# Login to Azure using az cli and follow instructions

az login

export ARM_SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)

# Create Terraform workspaces for state management
terraform workspace new dev
# Create plan and check what's being deployed
terraform plan -var="environment=dev"
# Perform deployment
terraform apply -var="environment=dev"

# Deploy other environments

terraform workspace new test
terraform plan -var="environment=test"
terraform apply -var="environment=test"

terraform workspace new prod
terraform plan -var="environment=prod"
terraform apply -var="environment=prod"
```
## Infrastructure teardown

```sh
terraform workspace select dev
terraform destroy

terraform workspace select test
terraform destroy

terraform workspace select prod
terraform destroy


```