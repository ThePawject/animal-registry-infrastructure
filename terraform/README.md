# ThePawject Infrastructure

Azure infrastructure as code using Terraform for the ThePawject application.

## Overview

This Terraform configuration provisions a consolidated Azure infrastructure supporting both development and production environments in a single resource group. The architecture uses shared resources where appropriate while maintaining proper environment isolation.

## Architecture

### Resource Group
- **Name**: `rg-thepawject`
- **Location**: `polandcentral`

### Resources

#### Networking
- **Virtual Network**: `thepawject-vnet` (10.0.0.0/16)
  - App Service subnet (10.0.1.0/24)
  - Private Endpoint subnet (10.0.2.0/24)
- **Private DNS Zone**: `privatelink.database.windows.net`

#### Compute
- **App Service Plan**: `thepawject-asp` (Linux, B1 SKU)
  - Shared between dev and prod environments
- **Web Apps**:
  - Dev: `thepawject-dev-api`
  - Prod: `thepawject-api`
  - Both integrated with VNet

#### Database
- **SQL Server**: `thepawject-sql`
  - Azure AD authentication only (no SQL auth)
  - Accessible via Private Endpoint
  - Public network access disabled
- **Databases**:
  - Dev: `dev-appdb` (Basic SKU)
  - Prod: `appdb` (Basic SKU)

#### Storage
- **Storage Account**: `thepawjectst` (Standard LRS)
- **Containers**:
  - Dev: `dev-animal-images` (public blob access)
  - Prod: `animal-images` (public blob access)

#### Static Web (Optional)
- Currently commented out in configuration
- Free tier available when enabled

## Prerequisites

### Required Tools
- Terraform >= 1.5.0
- Azure CLI

### Azure Requirements
- Azure subscription with Contributor access
- Azure AD user to serve as SQL Server admin
- User must have permissions to:
  - Create resources
  - Assign RBAC roles
  - Manage Azure AD directory objects

### Authentication
Authenticate with Azure CLI before running Terraform:
```bash
az login
az account set --subscription <subscription-id>
```

## Configuration

### Required Variables

Create `terraform/terraform.tfvars` with the following values:

```hcl
subscription_id     = "your-azure-subscription-id"
tenant_id           = "your-azure-tenant-id"
aad_admin_login     = "your-email@domain.com"
aad_admin_object_id = "your-azure-ad-user-object-id"
```

**Getting your Azure AD Object ID:**
```bash
az ad signed-in-user show --query id -o tsv
```

### Optional Variables

These have defaults but can be overridden in `terraform.tfvars`:

```hcl
project_name                    = "thepawject"          # Resource name prefix
location                        = "polandcentral"       # Azure region
app_service_sku                 = "B1"                  # App Service Plan SKU
dotnet_version                  = "9.0"                 # .NET runtime version
sql_sku                         = "Basic"               # SQL Database SKU
vnet_address_space              = ["10.0.0.0/16"]      # VNet CIDR
app_subnet_prefix               = "10.0.1.0/24"        # App subnet CIDR
private_endpoint_subnet_prefix  = "10.0.2.0/24"        # PE subnet CIDR
```

## Project Structure

```
terraform/
├── main.tf              # Main infrastructure configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
├── backend.tf           # State backend configuration
├── terraform.tfvars     # Your configuration values (gitignored)
└── modules/
    ├── appservice/      # App Service Plan and Web Apps
    ├── network/         # VNet, subnets, Private DNS
    ├── sql/             # SQL Server, databases, private endpoint
    ├── staticweb/       # Static Web App (optional)
    └── storage/         # Storage account and containers
```

## Deployment

### Initialize Terraform

```bash
cd terraform/
terraform init
```

This will:
- Initialize the backend
- Download required providers (azurerm, null)
- Initialize modules

### Preview Changes

```bash
terraform plan
```

Review the plan output. Expected resources: ~15-20 resources including:
- 1 Resource Group
- 1 VNet with 2 subnets
- 1 Private DNS Zone
- 1 Storage Account with 2 containers
- 1 SQL Server with 2 databases
- 1 Private Endpoint with DNS record
- 1 App Service Plan with 2 Web Apps
- 2 RBAC role assignments
- 2 Database user provisioning resources

### Apply Changes

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 10-15 minutes.

### Verify Deployment

```bash
# View outputs
terraform output

# Test dev API
curl https://thepawject-dev-api.azurewebsites.net/health

# Test prod API
curl https://thepawject-api.azurewebsites.net/health
```

## Security Features

### Authentication & Authorization
- **SQL Server**: Azure AD authentication only (SQL authentication disabled)
- **Web Apps**: System-assigned managed identities
- **Storage**: Access via managed identity (no keys in configuration)
- **Database**: Users automatically created for each web app identity

### Network Security
- **Private Endpoint**: SQL Server not exposed to internet
- **VNet Integration**: Web apps communicate with SQL via private network
- **Private DNS**: Automatic DNS resolution for private endpoints

### RBAC Roles
Automatically assigned:
- `Storage Blob Data Contributor` on storage account for both web apps
- SQL database roles for each web app:
  - `db_datareader` - Read data
  - `db_datawriter` - Write data
  - `db_ddladmin` - Schema changes (for Entity Framework migrations)

### CORS
Both web apps configured with:
- `http://localhost:3000` (local development)
- `https://thepawject.github.io` (GitHub Pages)
- Credentials support enabled

## Database Access

### Automatic User Provisioning

Database users are created automatically during `terraform apply` using Azure CLI:

- **Dev**: User `thepawject-dev-api` in database `dev-appdb`
- **Prod**: User `thepawject-api` in database `appdb`

Each user is granted:
- `db_datareader` - SELECT queries
- `db_datawriter` - INSERT, UPDATE, DELETE operations
- `db_ddladmin` - CREATE, ALTER, DROP schema objects

### Connection Strings

Automatically configured via app settings:

**Dev:**
```
Server=thepawject-sql.database.windows.net;Database=dev-appdb;Authentication=Active Directory Default;Encrypt=True;
```

**Prod:**
```
Server=thepawject-sql.database.windows.net;Database=appdb;Authentication=Active Directory Default;Encrypt=True;
```

### Manual User Creation

If automatic provisioning fails, create users manually:

```sql
-- Connect to dev-appdb as Azure AD admin
CREATE USER [thepawject-dev-api] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [thepawject-dev-api];
ALTER ROLE db_datawriter ADD MEMBER [thepawject-dev-api];
ALTER ROLE db_ddladmin ADD MEMBER [thepawject-dev-api];

-- Connect to appdb as Azure AD admin
CREATE USER [thepawject-api] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [thepawject-api];
ALTER ROLE db_datawriter ADD MEMBER [thepawject-api];
ALTER ROLE db_ddladmin ADD MEMBER [thepawject-api];
```

## Outputs

After successful deployment, Terraform outputs:

### Development Environment
- `dev_api_url` - Web app URL
- `dev_database_name` - Database name
- `dev_storage_container` - Storage container name

### Production Environment
- `prod_api_url` - Web app URL
- `prod_database_name` - Database name
- `prod_storage_container` - Storage container name

### Shared Resources
- `resource_group_name` - Resource group name
- `sql_server_name` - SQL Server name
- `storage_account_name` - Storage account name

## Cost Estimation

**Estimated monthly cost: ~$20-25/month**

| Resource | SKU/Tier | Quantity | Monthly Cost |
|----------|----------|----------|--------------|
| App Service Plan | B1 | 1 | ~$13 |
| SQL Database | Basic | 2 | ~$5 each = $10 |
| Storage Account | Standard LRS | 1 | ~$1-2 |
| VNet | Standard | 1 | Free |
| Private Endpoint | Standard | 1 | ~$0.01/GB processed |

*Costs are estimates and may vary by region and actual usage.*

**Notes:**
- SQL Server itself is free; you only pay for databases
- VNet is free; Private Endpoint charges are based on data processed
- Storage costs include minimal egress for public blob access

## Application Deployment

### Using Managed Identity

Your application automatically uses managed identity for:
- SQL Database authentication
- Storage Blob access

No connection strings or storage keys needed in code.

### Example: .NET Configuration

```csharp
// SQL Database - uses Azure AD authentication automatically
services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        configuration.GetConnectionString("Database__ConnectionString")));

// Storage - uses DefaultAzureCredential (managed identity)
var blobServiceClient = new BlobServiceClient(
    new Uri($"https://{accountName}.blob.core.windows.net"),
    new DefaultAzureCredential());
```

### Deployment Targets

**Development:**
- Web App: `thepawject-dev-api`
- Connection to: `dev-appdb` and `dev-animal-images`

**Production:**
- Web App: `thepawject-api`
- Connection to: `appdb` and `animal-images`

## Enabling Static Web App

The Static Web App is currently commented out. To enable:

1. Edit `terraform/main.tf`
2. Uncomment lines 139-145:
```hcl
module "staticweb" {
  source              = "./modules/staticweb"
  name_prefix         = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku_tier            = "Free"
  sku_size            = "Free"
}
```
3. Run `terraform apply`

## State Management

This configuration uses local Terraform state by default. The state file is stored at:
```
terraform/terraform.tfstate
```

**Important:** 
- Do not commit `terraform.tfstate` to version control
- Already excluded via `.gitignore`
- Consider migrating to remote state (Azure Storage) for team collaboration

## Maintenance

### Viewing Current State

```bash
terraform show
```

### Listing Resources

```bash
terraform state list
```

### Refreshing State

```bash
terraform refresh
```

### Destroying Resources

To delete all infrastructure:

```bash
terraform destroy
```

**Warning:** This permanently deletes:
- All databases and data
- All storage containers and blobs
- All web apps and configurations
- The entire resource group

## Troubleshooting

### Database User Creation Fails

**Symptoms:** `null_resource.grant_app_service_db_access` fails during apply

**Causes:**
- Not authenticated with Azure CLI
- Not the SQL Server Azure AD admin
- Network connectivity issues

**Resolution:**
1. Verify authentication:
   ```bash
   az account show
   ```

2. Verify you're the admin specified in `aad_admin_login`

3. If it continues to fail, create users manually (see Database Access section)

### Web App Can't Connect to SQL

**Symptoms:** Application logs show SQL connection errors

**Checklist:**
- ✓ VNet integration enabled on web app
- ✓ Private endpoint created and connected
- ✓ Private DNS zone linked to VNet
- ✓ Database user exists for the web app's managed identity
- ✓ Connection string uses `Authentication=Active Directory Default`

**Verify private endpoint:**
```bash
az network private-endpoint list \
  --resource-group rg-thepawject \
  --output table
```

### Storage Access Denied

**Symptoms:** Application can't read/write blobs

**Resolution:**
1. Verify RBAC role assignment:
   ```bash
   az role assignment list \
     --scope /subscriptions/{sub-id}/resourceGroups/rg-thepawject/providers/Microsoft.Storage/storageAccounts/thepawjectst \
     --assignee {web-app-managed-identity-object-id}
   ```

2. Verify managed identity is enabled on web app

3. Ensure application uses `DefaultAzureCredential`

### Terraform State Lock

**Symptoms:** `Error acquiring the state lock`

**Cause:** Previous operation didn't complete properly

**Resolution:**
Since using local state, manually delete the lock file:
```bash
rm .terraform/terraform.tfstate.lock.info
```

## Module Reference

### appservice
Creates App Service Plan and Web Apps with managed identity.

**Inputs:**
- `name_prefix` - Resource name prefix
- `location` - Azure region
- `resource_group_name` - Resource group
- `service_plan_id` - External service plan ID (optional)
- `dotnet_version` - .NET runtime version
- `subnet_id` - VNet subnet for integration
- `app_settings` - Environment variables

### network
Creates VNet, subnets, and Private DNS zone.

**Inputs:**
- `name_prefix` - Resource name prefix
- `location` - Azure region
- `resource_group_name` - Resource group
- `address_space` - VNet CIDR
- `app_subnet_prefix` - App subnet CIDR
- `private_endpoint_subnet_prefix` - Private endpoint subnet CIDR

### sql
Creates SQL Server, databases, private endpoint, and database users.

**Inputs:**
- `name_prefix` - Resource name prefix
- `location` - Azure region
- `resource_group_name` - Resource group
- `aad_admin_login` - Azure AD admin username
- `aad_admin_object_id` - Azure AD admin object ID
- `aad_admin_tenant_id` - Azure AD tenant ID
- `database_names` - List of database names
- `sku_name` - Database SKU
- `app_service_identities` - Map of managed identities for access grants

### storage
Creates Storage Account with multiple containers.

**Inputs:**
- `name_prefix` - Resource name prefix
- `location` - Azure region
- `resource_group_name` - Resource group
- `container_names` - List of container names
- `account_tier` - Storage account tier
- `replication_type` - Replication type

### staticweb
Creates Static Web App (currently commented out).

**Inputs:**
- `name_prefix` - Resource name prefix
- `location` - Azure region
- `resource_group_name` - Resource group
- `sku_tier` - SKU tier
- `sku_size` - SKU size

## Additional Resources

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure SQL Database Documentation](https://docs.microsoft.com/en-us/azure/azure-sql/)
- [Managed Identities Documentation](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues or questions:
- Review Terraform output for error details
- Check Azure Portal for resource status
- Verify authentication and permissions
- Consult troubleshooting section above
