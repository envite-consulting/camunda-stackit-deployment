# Camunda STACKIT Deployment

[![Camunda](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![Terraform](https://img.shields.io/badge/Terraform-5835CC)](https://developer.hashicorp.com/terraform/tutorials?product_intent=terraform)

Bereitstellung von Referenzkonfigurationen und Beispielen für das Deployment von Camunda 8 auf STACKIT. Dieses
Repository erweitert die offiziellen Camunda Deployment References um spezifische Anleitungen, Infrastruktur-Templates
und Best Practices für STACKIT.

---

# Manuelle Anleitung – Ist-Zustand

> Status: funktional, aber stark manuell; Ausgangspunkt für spätere Automatisierung

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
cp config.s3.tfbackend.example config.s3.tfbackend
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

Ergebnis (implizit):

* SKE Cluster
* Postgres
* OpenSearch
* Outputs (Credentials, Endpoints)

---

## Kubernetes Zugriff

### 4.1 Cluster anzeigen

```bash
stackit ske cluster list
```

### 4.2 kubeconfig erzeugen

```bash
stackit ske kubeconfig create camunda8 --login
```

---

## Plattform-Komponenten via Helm

### 5.1 ingress-nginx

```bash
helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  --install \
  --namespace ingress-nginx \
  --create-namespace \
  --version 4.12.1 \
  --values helm-values/ingress-nginx/values.yaml
```

---

### 5.2 cert-manager

```bash
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.2 \
  --values helm-values/cert-manager/values.yaml
```

ClusterIssuer:

```bash
kubectl apply -f helm-values/cert-manager/clusterissuer-letsencrypt-production.yaml
```

---

### 5.3 NATS

```bash
helm upgrade --install nats nats/nats \
  --namespace nats \
  --create-namespace \
  --version 1.3.3 \
  --values helm-values/nats/values.yaml
```

---

## Namespaces

```bash
kubectl create namespace camunda8
kubectl create namespace keycloak
```

---

## Keycloak Installation

### 7.1 CRDs & Operator

```bash
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.4.5/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.4.5/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl -n keycloak apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.4.5/kubernetes/kubernetes.yml
```

---

### 7.2 Keycloak DB Secret

```bash
kubectl create secret -n keycloak generic keycloak-db-secret-user \
  --from-literal=username=keycloak
```

---

### 7.3 PostgreSQL für Keycloak

```bash
helm install keycloak-db bitnami/postgresql \
  --namespace keycloak \
  --set auth.postgresPassword=<CHANGE_ME> \
  --set auth.username=<CHANGE_ME> \
  --set auth.password=<CHANGE_ME> \
  --set auth.database=keycloak
```

---

### 7.4 Keycloak Manifeste

```bash
kubectl apply -f helm-values/keycloak/ingress.yaml
kubectl apply -f helm-values/keycloak/keycloak.yaml
```

---

### 7.5 Admin Passwort auslesen

```bash
kubectl get secret -n keycloak camunda-keycloak-initial-admin -o yaml
```

Manuell extrahieren:

```text
data.password → base64 decode
```

---

## Camunda Identity Secrets

```bash
kubectl create secret generic identity-secret-for-components \
  --namespace camunda8 \
  --from-literal=identity-admin-client-token="keycloak-admin" \
  --from-literal=identity-first-user-password="<CHANGE_ME>" \
  --from-literal=identity-connectors-client-token="..." \
  --from-literal=identity-orchestration-client-token="..."
```

---

## Terraform Outputs → Kubernetes Secrets

⚠️ Terraform Outputs enthalten sensitive Daten und dürfen nicht geloggt, committed oder geteilt werden.

### 9.1 OpenSearch

```bash
terraform output -raw opensearch_password
kubectl create -n camunda8 secret generic opensearch-credentials \
  --from-literal=password=opensearch-password
```

---

### 9.2 Postgres

```bash
terraform output -raw postgres_dsn
```

Manuell:

* Passwort extrahieren (`camunda_user:<PASSWORD>@`)

```bash
kubectl create -n camunda8 secret generic identity-db-secret \
  --from-literal=database-password=postgres-password
```

---

## OpenSearch ACL manuell setzen

Im STACKIT Portal:

* OpenSearch → ACL
* IP des Kubernetes Clusters hinzufügen

IP ermitteln:

```bash
kubectl run -it --rm debug --image=alpine -- sh -c \
  "apk add curl; curl ifconfig.me"
```

---

## Camunda Deployment

```bash
helm install camunda camunda/camunda-platform \
  --namespace camunda8 \
  -f helm-values/camunda/values.yaml
```

`values.yaml` enthält:

* OpenSearch Endpoint
* Credentials
* Object Storage Keys
* Postgres DSN

---

## Referenzen für spätere Erweiterungen

* Identity Secret:
  [https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh](https://github.com/camunda/camunda-deployment-references/blob/stable/8.8/generic/openshift/single-region/procedure/create-identity-secret.sh)
* Docs:
  [https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/](https://docs.camunda.io/docs/self-managed/deployment/helm/configure/authentication-and-authorization/internal-keycloak/)

---