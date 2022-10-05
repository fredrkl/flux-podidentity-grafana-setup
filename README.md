# Flux Pod identity Grafana Setup

This repo shows how to set up AKS with advanced networking, grafana, postgress, and flux image scanning using pod identity towards _Azure Container Registry_.

## Setup

1. Clone/Fork this repo
2. Create an RG in Azure and note down the name
3. Create a GitHub secret holding an Azure Service Principal following this guide: <https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md> giving it access to the RG in step 2. Give it the name AZURE_CREDENTIALS.
4. 
