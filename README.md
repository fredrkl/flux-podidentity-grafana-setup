# Flux Pod identity Grafana Setup

This repo shows how to set up AKS with advanced networking, private endpoints, Grafana, Postgress, and flux image scanning using pod identity toward _Azure Container_ Registry_.

## Setup

1. Clone/Fork this repo
2. Create a GitHub secret holding an Azure Service Principal following this guide: <https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md>. Give it access to a _subscription_ that you want to deploy to. Give it the name AZURE_CREDENTIALS.
3. Kick off the GitHub Action

## Notes

- This repo also shows in the git commit <https://github.com/fredrkl/flux-podidentity-grafana-setup/commit/44e752473f815d2fc70da77b5185e6b913c423c8> how to apply yaml when the cluster API server is private, or your GitHub action runners lack access by using the [_az aks command_](https://learn.microsoft.com/en-us/cli/azure/aks/command?view=azure-cli-latest).
- It also shows how to setup private endpoints for storage and _azure container registry_