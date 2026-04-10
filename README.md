# Camunda STACKIT Deployment

[![Camunda](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![Terraform](https://img.shields.io/badge/Terraform-5835CC)](https://developer.hashicorp.com/terraform/tutorials?product_intent=terraform)

Provision of reference configurations and examples for deploying Camunda 8 on [STACKIT](https://stackit.com/en). This repository builds up on the official [Camunda Deployment References](https://github.com/camunda/camunda-deployment-references/tree/stable/8.8?tab=readme-ov-file) with specific instructions, infrastructure templates, and best practices for STACKIT.

# Table of Contents

* [Local requirements](#local-requirements)
  * [`Terraform` Installation](#terraform-installation)
  * [`STACKIT CLI` Installation](#stackit-cli-installation)
* [STACKIT Access & Project Configuration](#stackit-access--project-configuration)
  * [Create a service account for Terraform](#create-a-service-account-for-terraform)
* [Terraform Backend (STACKIT Object Storage / S3)](#terraform-backend-stackit-object-storage--s3)
  * [Credentials Group for Terraform State](#credentials-group-for-terraform-state)
  * [Create S3 Credentials](#create-s3-credentials)
  * [Configure Terraform Backend](#configure-terraform-backend)
* [Terraform Infrastructure Deployment](#terraform-infrastructure-deployment)
  * [Terraform apply](#terraform-apply)
  * [Destroy / Ressourcen cleanup:](#destroy--ressourcen-cleanup)
* [Kubernetes Access](#kubernetes-access)
* [Accessing Camunda Console](#accessing-camunda-console)

## Local requirements

### `Terraform` Installation

Documentation: [Install Terraform](https://developer.hashicorp.com/terraform/install)

Required version: "1.14.7"

### `STACKIT CLI` Installation

Documentation: [STACKIT CLI](https://github.com/stackitcloud/stackit-cli/blob/main/INSTALLATION.md)

---

## STACKIT Access & Project Configuration

```bash
# Login to STACKIT
stackit auth login

# Select project
stackit project list
stackit config set --project-id <PROJECT-ID>
```

---

### Create a service account for Terraform

Documentation: [Create a Service Account](https://docs.stackit.cloud/stackit/en/create-a-service-account-134415839.html)

> [!WARNING]
> If a service account already exists in the team, **no new service account needs to be created**.  
> In this case, the **existing `sa_key.json`** is used.
>
> Requirements:
> - Access to the existing `sa_key.json`
> - File is available locally
> - File is entered in `.gitignore`

Create a new Service Account:

```bash
stackit service-account create --name <SERVICE_ACCOUNT_NAME>
```

Add service account to the project:

```bash
stackit project member add <SERVICE_ACCOUNT_NAME>@sa.stackit.cloud --role editor
```

---

## Terraform Backend (STACKIT Object Storage / S3)

> [!WARNING]
> If the object storage, bucket, and credentials group already exist for this project, **these steps do not need to be performed again**.  
> In this case, the existing configuration can be used directly for the Terraform backend.
>
> Prerequisites:
> - Access to existing bucket and credential data
> - Local file `config.s3.tfbackend` exists or can be created using existing keys
> - All sensitive data is entered in `.gitignore`

```bash
# Enable object storage
stackit object-storage enable

# Create Bucket for Terraform State
stackit object-storage bucket create tfstate-bucket-camunda-ske-deployment
```

---

### Credentials Group for Terraform State

```bash
stackit object-storage credentials-group create --name terraform-state
```

Result:

* Credentials Group ID
* URN

---

### Create S3 Credentials

Use `CREDENTIAL_GROUP_ID` generated in previous step.

```bash
stackit object-storage credentials create --credentials-group-id <CREDENTIAL_GROUP_ID>
```

Generates:

* Access Key
* Secret Access Key
* **Expiration Date: Never**

---

### Configure Terraform Backend

> [!NOTE]
> Replace `<environment>` with the target environment directory (e.g. `single-region`).

Configure S3 Bucket

```bash
cp environments/<environment>/config.s3.example.tfbackend environments/<environment>/config.s3.tfbackend
```

Adjust `secret_key` and `access_key`:

```hcl
access_key = "<S3_ACCESS_KEY>"
secret_key = "<S3_SECRET_KEY>"
bucket     = "tfstate-bucket-camunda-ske-deployment"
key        = "camunda_ske_deployment.tfstate"
```

Configure remaining terraform variables by copying `terraform.example.tfvars` to `terraform.tfvars` (`cp environments/<environment>/terraform.example.tfvars environments/<environment>/terraform.tfvars`) and replacing the placeholders.

Create Service Account Key or reference:

```bash
cd environments/<environment>/
stackit service-account key create --email <SERVICE_ACCOUNT_NAME>@sa.stackit.cloud > sa_key.json
```

If you already have one, you could copy it and adopt the name if necessary in [`variables.tf`](./environments/<environment>/variables.tf) (`sa_key_file_name`).

---

## Terraform Infrastructure Deployment

### Terraform apply

```bash
cd environments/<environment>/
terraform init --backend-config=./config.s3.tfbackend
terraform plan
terraform apply
```

Result:

Running instances of:

* SKE Cluster
* Postgres
* OpenSearch
* Secrets Manager
* Keycloak
* Camunda 8

### Destroy / Ressourcen cleanup:

```bash
terraform destroy
```

> [!IMPORTANT]
> terraform destroy deletes all instances listed above and cannot be undone.

---

## Kubernetes Access

```bash
# View Cluster
stackit ske cluster list

# Create kubeconfig
stackit ske kubeconfig create <environment> --login
```

---

## Accessing Camunda Console

1. Access the Camunda Console via `https://<dns_name>/console`.

   The `dns_name` value is provided as an input variable to the `camunda-workflow-engine` module.  
   This value is environment-specific and is typically set through Terraform variables (for example in the target environment's `terraform.tfvars`).

2. Log in with the initial Camunda user defined through the `camunda_initial_user` input variable passed to the `camunda-workflow-engine` module.  
   The login username is taken from the `username` field of that input variable (`camunda_initial_user.username`).

   The password is generated automatically and can be viewed in the STACKIT Secrets Manager portal:

    - Secret: `camunda-passwords`
    - Key: `firstUser`

   How to view secrets: [STACKIT – View, create and delete secrets](https://docs.stackit.cloud/products/security/secrets-manager/getting-started/view-create-and-delete-secrets/#view-secrets)

---

## References for later extensions

* Identity Secret:
  [https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh](https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh)
* Docs:
  [https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/](https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/)

---
