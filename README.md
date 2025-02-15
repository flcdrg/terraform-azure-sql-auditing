# Enabling Azure SQL auditing with Terraform

Enabling Azure SQL extended auditing in Terraform using [azurerm_mssql_server_extended_auditing_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) and [azurerm_monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting)

See also:

- <https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/extendedauditingsettings?pivots=deployment-language-bicep&WT.mc_id=DOP-MVP-5001655>
- <https://learn.microsoft.com/azure/azure-sql/database/auditing-server-level-database-level?view=azuresql&WT.mc_id=DOP-MVP-5001655>

## Developer/environment configuration

In HCP Terraform:

1. New | Workspace
2. Select project
3. Click **Create**
4. Select CLI-driven workflow
5. Enter workspace name 'terraform-azure-sql-auditing'

<https://www.hashicorp.com/en/blog/access-azure-from-hcp-terraform-with-oidc-federation>

<https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/azure-configuration>

1. Create Azure resource group

    ```bash
    az group create --name rg-terraform-sql-auditing-australiaeast --location australiaeast
    ```

2. Create service principal and role assignments

    ```bash
    az ad sp create-for-rbac --name sp-terraform-sql-auditing-australiaeast --role Contributor --scopes /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-terraform-sql-auditing-australiaeast

    az role assignment create --assignee sp-terraform-sql-auditing-australiaeast --role " Role Based Access Control Administrator" --scope /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-terraform-sql-auditing-australiaeast
    ```

Make a note of the appID and tenant ID

Create credential.json

```json
{
    "name": "tfc-plan-credential",
    "issuer": "https://app.terraform.io",
    "subject": "organization:flcdrg:project:my-project-name:workspace:terraform-azure-sql-auditing:run_phase:plan",
    "description": "Terraform Plan",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
```

And create federated credentials for your service principal. The `--id` parameter should be set to the appId that you noted previously.

```bash
az ad app federated-credential create --id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --parameters credential.json
```

Update the credential.json file and replace 'plan' with 'apply' (3 places). Create a second federated credential by running the above command again.

Back in HCP Terraform, set the following environment variables in your workspace

`TFC_AZURE_PROVIDER_AUTH` = true
`TFC_AZURE_RUN_CLIENT_ID` = \<appId value\>
`ARM_SUBSCRIPTION_ID` = Azure subscription id
`ARM_TENANT_ID` = Azure tenant id

And the following Terraform variables:

`mssql_azuread_administrator_object_id` = the Entra ID object ID of an account to set as administrator

Click on your profile and select **Account settings**, then **Tokens**.
Click on **Create an API token**
In **Description** field enter `
6. Review (and adjust if required) the expiration date
7. Click **Create**
8. Note the token value.

To allow the GitHub Action workflows to connect to HCP Terraform, in the GitHub project

1. Go to **Settings**, **Secrets and Variables**
2. In **Actions**, click on **New repository secret**
3. In **Name**, enter `TF_API_TOKEN`
4. In **Secret**, paste the HCP Terraform token, and click **Add secret**
