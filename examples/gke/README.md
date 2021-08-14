# gke

Example installation of Coder onto Google Kubernetes Engine in Google Cloud
Platorm. It requires [terragrunt](https://terragrunt.gruntwork.io/) to run.

The only preexisting resources required is the Cloud DNS zone which your
cluster hostname will be created in.

To get started, first fill out `terragrunt.hcl` with the correct variables for
your deployment. Finally, run:

```bash
terragrunt run-all apply
```
