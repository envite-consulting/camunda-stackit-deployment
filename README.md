# Camunda STACKIT Deployment

[![Camunda](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![Terraform](https://img.shields.io/badge/Terraform-5835CC)](https://developer.hashicorp.com/terraform/tutorials?product_intent=terraform)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/envite-consulting/camunda-stackit-deployment)

Provision of reference configurations and examples for deploying Camunda 8 on [STACKIT](https://stackit.com/en). This repository builds up on the official [Camunda Deployment References](https://github.com/camunda/camunda-deployment-references/tree/stable/8.8?tab=readme-ov-file) with specific instructions, infrastructure templates, and best practices for STACKIT.

# Table of Contents

* [Local requirements](#local-requirements)
    * [`Terraform` Installation](#terraform-installation)
    * [`STACKIT CLI` Installation](#stackit-cli-installation)
* [STACKIT Access & Project Configuration](#stackit-access--project-configuration)
* [Service accounts](#service-accounts)
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
* [References for later extensions](#references-for-later-extensions)

## Local requirements

### `Terraform` Installation

Documentation: [Install Terraform](https://developer.hashicorp.com/terraform/install)

Required version: "1.16.3"

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

## Service accounts

The deployment uses one service account:

| Service account | Used by | Role | Key file | Variable |
|---|---|---|---|---|
| terraform | Terraform, to provision all resources | `editor` | `sa_key.json` | `sa_key_file_name` |

> [!WARNING]
> If this service account already exists in the team, **do not create a new one**. Copy its existing key file into `environments/<environment>/` instead; if the file name differs, set the variable from the table above.
>
> Key files are matched by `.gitignore` (`sa_key*.json`). **Never commit them.**

> [!NOTE]
> On Windows, run these commands in PowerShell 7 (`pwsh`) or a Bash shell. Windows PowerShell 5.1 writes redirected output (`>`) as UTF-16, which Terraform's `file()` function rejects as invalid UTF-8.

Documentation: [Create a Service Account](https://docs.stackit.cloud/stackit/en/create-a-service-account-134415839.html)

### Create a service account for Terraform

Create a new service account:

```bash
stackit service-account create --name <SERVICE_ACCOUNT_NAME>
```

Add the service account to the project:

```bash
stackit project member add <SERVICE_ACCOUNT_NAME>@sa.stackit.cloud --role editor
```

Create a key for the service account:

```bash
cd environments/<environment>/
stackit service-account key create --email <SERVICE_ACCOUNT_NAME>@sa.stackit.cloud > sa_key.json
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

Configure the remaining Terraform variables by copying `terraform.tfvars.example` to `terraform.tfvars` (`cp environments/<environment>/terraform.tfvars.example environments/<environment>/terraform.tfvars`) and replacing the placeholders.

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

   `dns_name` is a variable of the environment, set in its `terraform.tfvars`.

2. Log in with the initial Camunda user defined by the `camunda_initial_user` variable.  
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
