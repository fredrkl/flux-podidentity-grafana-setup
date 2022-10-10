# Flux Pod identity Grafana Setup

This repo shows how to set up AKS with advanced networking, private endpoints, grafana, postgress, and flux image scanning using pod identity towards _Azure Container Registry_.

## Setup

1. Clone/Fork this repo
2. Create a GitHub secret holding an Azure Service Principal following this guide: <https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md> giving it access to a _subscription_ that you want to deploy to. Give it the name AZURE_CREDENTIALS.
