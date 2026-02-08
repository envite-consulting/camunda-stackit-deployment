# Camunda STACKIT Deployment

[![Camunda](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![Terraform](https://img.shields.io/badge/Terraform-5835CC)](https://developer.hashicorp.com/terraform/tutorials?product_intent=terraform)

Bereitstellung von Referenzkonfigurationen und Beispielen für das Deployment von Camunda 8 auf STACKIT. Dieses
Repository erweitert die offiziellen Camunda Deployment References um spezifische Anleitungen, Infrastruktur-Templates
und Best Practices für STACKIT.

---

## Lokale Voraussetzungen

### 0.1 Terraform installieren

Dokumentation:
[Install Terraform](https://developer.hashicorp.com/terraform/install)

### 0.2 STACKIT CLI installieren

Dokumentation:
[STACKIT CLI](https://github.com/stackitcloud/stackit-cli/blob/main/INSTALLATION.md)

---

## STACKIT Zugriff & Projektkonfiguration

### 1.1 Login in STACKIT

```bash
stackit auth login
```

### 1.2 Projekt auswählen

```bash
stackit project list
stackit config set --project-id PROJECTx-IDyy-zzzz-aaaa-DUMMYbbbbbbb
```

---

### 1.3 Service Account für Terraform erstellen

Dokumentation:
[Create a Service Account](https://docs.stackit.cloud/stackit/en/create-a-service-account-134415839.html)

> [!WARNING]
> Falls im Team bereits ein Service Account existiert, **muss kein neuer Service Account erstellt werden**.  
> In diesem Fall wird das **bereits vorhandene `sa_key.json`** verwendet.
>
> Voraussetzungen:
> - Zugriff auf das bestehende `sa_key.json`
> - Datei liegt lokal vor
> - Datei ist in `.gitignore` eingetragen

#### Neuen Service Account erstellen

```bash
stackit service-account create --name terraform
```

* erzeugt `sa_key.json`
* Datei wird **lokal abgelegt**
* muss in `.gitignore` stehen

Service Account dem Projekt hinzufügen:

```bash
stackit project member add terraform-<SERVICE_ACCOUNT_ID>@sa.stackit.cloud --role editor
```

---

## Terraform Backend (STACKIT Object Storage / S3)

> [!WARNING]
> Falls der Object Storage, der Bucket und die Credentials Group bereits für dieses Projekt existieren, **müssen diese Schritte nicht erneut durchgeführt werden**.  
> In diesem Fall kann direkt die bestehende Konfiguration für das Terraform Backend verwendet werden.
>
> Voraussetzungen:
> - Zugriff auf bestehende Bucket- und Credential-Daten
> - Lokale Datei `config.s3.tfbackend` ist vorhanden oder kann anhand bestehender Keys erstellt werden
> - Alle sensiblen Daten sind in `.gitignore` eingetragen

### 2.1 Object Storage aktivieren

```bash
stackit object-storage enable
```

### 2.2 Bucket für Terraform State anlegen

```bash
stackit object-storage bucket create tfstate-bucket-camunda-ske-deployment
```

---

### 2.3 Credentials Group für Terraform State

```bash
stackit object-storage credentials-group create --name terraform-state
```

Ergebnis:

* Credentials Group ID
* URN

---

### 2.4 S3 Credentials erzeugen

```bash
stackit object-storage credentials create --credentials-group-id myCredGroup
```

Erzeugt:

* Access Key
* Secret Access Key
* **Expire Date: Never**

---

### 2.5 Terraform Backend konfigurieren

```bash
cp config.s3.example.tfbackend config.s3.tfbackend
```

Manuell anpassen:

```hcl
secret_key = "<S3_SECRET_KEY>"
access_key = "<S3_ACCESS_KEY>"
bucket     = "tfstate-bucket-camunda-ske-deployment"
key        = "camunda_ske_deployment.tfstate"
```

---

## Terraform Infrastruktur Deployment

### 3.1 Terraform ausführen

```bash
terraform init --backend-config=./config.s3.tfbackend
terraform plan
terraform apply
```

Ergebnis:

Laufende Instanzen von:
* SKE Cluster
* Postgres
* OpenSearch
* Secrets Manager
* Keycloak
* Camunda 8

### 3.2 Aufräumen / Ressourcen löschen:

```bash
terraform destroy
```

> [!IMPORTANT]
> terraform destroy löscht alle oben aufgeführten Instanzen und kann nicht rückgängig gemacht werden.

---

## Kubernetes Zugriff

### 4.1 Cluster anzeigen

```bash
stackit ske cluster list
```

### 4.2 kubeconfig erzeugen

```bash
stackit ske kubeconfig create camunda --login
```

---

## Referenzen für spätere Erweiterungen

* Identity Secret:
  [https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh](https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh)
* Docs:
  [https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/](https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/)

---