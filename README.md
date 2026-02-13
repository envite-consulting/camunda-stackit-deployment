# Camunda STACKIT Deployment

[![Camunda](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![Terraform](https://img.shields.io/badge/Terraform-5835CC)](https://developer.hashicorp.com/terraform/tutorials?product_intent=terraform)

Provision of reference configurations and examples for deploying Camunda 8 on [STACKIT](https://stackit.com/en). This repository builds up on the official [Camunda Deployment References](https://github.com/camunda/camunda-deployment-references/tree/stable/8.8?tab=readme-ov-file) with specific instructions, infrastructure templates, and best practices for STACKIT.

# Table of Contents

* [Local requirements](#local-requirements)
  * [`Terraform` Installation](#terraform-installation-)
  * [`STACKIT CLI` Installation](#stackit-cli-installation-)
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

## Local requirements

### `Terraform` Installation 

Documentation: [Install Terraform](https://developer.hashicorp.com/terraform/install)

### `STACKIT CLI` Installation 

Documentation: [STACKIT CLI](https://github.com/stackitcloud/stackit-cli/blob/main/INSTALLATION.md)

---

## STACKIT Access & Project Configuration

```bash
# Login in to STACKIT
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

Use `CREADENTIAL_GROUP_ID` generated in  previous step. 

```bash
stackit object-storage credentials create --credentials-group-id <CREADENTIAL_GROUP_ID>
```

Generates:

* Access Key
* Secret Access Key
* **Expiration Date: Never**

---

### Configure Terraform Backend

Configure S3 Bucket

```bash
cp tf/config.s3.example.tfbackend tf/config.s3.tfbackend
```

Adjust `secret_key` and `access_key`:

```hcl
access_key = "<S3_ACCESS_KEY>"
secret_key = "<S3_SECRET_KEY>"
bucket     = "tfstate-bucket-camunda-ske-deployment"
key        = "camunda_ske_deployment.tfstate"
```

Configure remaining terraform variables by copying `terraform.example.tfvars` to `terraform.tfvars` (`cp terraform.example.tfvars terraform.tfvars`) and replacing the placeholders.

Create Service Account Key or reference:

```bash
cd tf/
stackit service-account key create --email <SERVICE_ACCOUNT_NAME>@sa.stackit.cloud > sa_key.json
```

If you already have one, you could copy it and adopt the name if necessary in [`variables.tf`](./tf/variables.tf) (`sa_key_file_name`).

---

## Terraform Infrastructure Deployment

### Terraform apply

```bash
cd tf/
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
stackit ske kubeconfig create camunda --login
```

---

## Limitation

Currently only the Orchestration Cluster is supported. The Web Modeler and Console will follow. For the distinction, see [Camunda docs](https://docs.camunda.io/docs/self-managed/reference-architecture/#orchestration-cluster-vs-web-modeler-and-console).

## References for later extensions

* Identity Secret:
  [https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh](https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh)
* Docs:
  [https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/](https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/)

---