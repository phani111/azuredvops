<#
This PowerShell script creates an Azure Container Apps environment and an Azure Container App within that environment.

The script performs the following actions:
- Creates a new resource group with the name "rg-containerapps-azure-pipelines" in the "westeurope" location.
- Creates a new Azure Container Apps environment with the name "aca-environment" in the "westeurope" location and the "rg-containerapps-azure-pipelines" resource group.
- Creates a new Azure Container App with the name "album-backend-api" in the "aca-environment" environment, the "rg-containerapps-azure-pipelines" resource group, and uses the "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" container image. The container app is configured to listen on port 80 and have external ingress.
if it fails in 1st run then execute  az provider register -n Microsoft.OperationalInsights --wait
#>

$RESOURCE_GROUP = "rg-containerapps-azure-pipelines"
$LOCATION = "westeurope"
$CONTAINERAPPS_ENVIRONMENT = "aca-environment"
$CONTAINERAPPS_APP = "album-backend-api"

az group create `
	--name $RESOURCE_GROUP `
	--location $LOCATION

az containerapp env create `
	--name $CONTAINERAPPS_ENVIRONMENT `
	--resource-group $RESOURCE_GROUP `
	--location $LOCATION

az containerapp create `
	--name $CONTAINERAPPS_APP `
	--resource-group $RESOURCE_GROUP `
	--environment $CONTAINERAPPS_ENVIRONMENT `
	--image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest `
	--target-port 80 `
	--ingress 'external'

# Creates a service principal with the Contributor role scoped to the specified resource group.
# This allows the service principal to manage resources within the resource group.
#
# Parameters:
# - $RESOURCE_GROUP: The name of the resource group to scope the service principal to.
#
# Returns:
# The ID of the created service principal.
$RESOURCE_GROUP_ID = $(az group show --name $RESOURCE_GROUP --query id -o tsv)
echo $RESOURCE_GROUP_ID
az ad sp create-for-rbac -n "spn-aca-azure-pipelines" --role Contributor --scope $RESOURCE_GROUP_ID
$RESOURCE_GROUP_ID = $(az group show --name $RESOURCE_GROUP --query id -o tsv)

echo $RESOURCE_GROUP_ID

az ad sp create-for-rbac -n "spn-aca-azure-pipelines" --role Contributor --scope $RESOURCE_GROUP_ID