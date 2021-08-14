# enterprise-terraform

Single command deployments for Coder on a variety of scenarios.

Currently only Google Cloud Platform is supported. Head to the [GKE self hosted
example][gcp-self-hosted] to get started.

## Status

We plan on expanding our library of Terraform modules and examples. See below
for a table outlining what we currently have planned or in progress.

| Cloud                 | Self Hosted           | Workspace Provider |
| --------------------- | --------------------- | ------------------ |
| Google Cloud Platform | [✅][gcp-self-hosted] | ⌚                 |
| Azure                 | ⌚                    | ⌚                 |
| Amazon Web Services   | ⌚                    | ⌚                 |
| Digital Ocean         | ❌                    | ❌                 |

✅: Completed  
🚧: In Progress  
⌚: Planned  
❌: Not Currently Planned

[gcp-self-hosted]: https://github.com/cdr/enterprise-terraform/tree/master/examples/gke/self-hosted
