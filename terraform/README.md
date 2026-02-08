# ThePawject Infrastructure (Terraform)

## Overview
This repo provisions two Azure environments: `dev` and `prod`.

### Environments
- **dev**: SQL is public.
- **prod**: SQL is private via Private Endpoint + VNet integration for the API.

### Services
- Static Web App (Free)
- Linux App Service Plan (B1)
- Azure SQL Database (Basic)
- Storage Account (Standard LRS)
  - Public container for images

## Prerequisites
- Terraform >= 1.5
- Azure CLI login to the subscription
- Azure AD user that will be SQL AAD admin

## Project Structure
```
terraform/
  modules/
    appservice/
    network/
    sql/
    staticweb/
    storage/
  environments/
    dev/
    prod/
```

## Inputs to Provide
Set these variables in each environment's `terraform.tfvars`:
- `subscription_id`
- `tenant_id`
- `aad_admin_login` (AAD user display name or UPN)
- `aad_admin_object_id` (AAD object id for the admin user)

## Local State Setup
This configuration starts with local Terraform state files. No remote state storage is required.

## Workflow (Dev)
From `terraform/environments/dev`:
1. `terraform init`
2. `terraform plan -out tfplan`
3. `terraform apply tfplan`

## Workflow (Prod)
From `terraform/environments/prod`:
1. `terraform init`
2. `terraform plan -out tfplan`
3. `terraform apply tfplan`

## CI/CD Notes
- API is deployed by your pipeline into the App Service.
- Use system-assigned managed identity for SQL + Storage access.
- Add app settings in your pipeline if needed for connection strings.

## Outputs
After apply, Terraform outputs:
- API URL
- Static Web App URL
- Storage public container URL
- SQL server FQDN
- Storage account name

## Cleanup
From the environment directory:
- `terraform destroy`
