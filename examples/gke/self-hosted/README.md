# GKE Self Hosted Installer

Example installation of Coder onto Google Kubernetes Engine in Google Cloud
Platorm. It requires [terragrunt](https://terragrunt.gruntwork.io/) to run.

The only preexisting resources required is the Cloud DNS zone which your
cluster hostname will be created in.

## Getting Started

### Copy This Example

First, copy this example to a location of your choosing. We strongly suggest
version controlling it!

### Create a Cloud DNS Zone

A Cloud DNS zone that will contain the desired hostname must be created prior
to deploying. It must be in the same GCP project you plan to deploy Coder into.

For help creating a Cloud DNS zone, see the
[docs](https://cloud.google.com/dns/docs/zones).

### Deploying

After creating a Cloud DNS zone that contains the hostname Coder will be
deployed on, we're ready to get started.

First, fill out the `terragrunt.hcl` file. It contains all of the options
necessary to customize your Coder deployment.

Once everything has been filled out, you can view all proposed infrastructure
changes:

```bash
terragrunt run-all plan
```

If `plan` fails, it's possible some variables were improperly configured.
Inspect the output to remedy any issues.

Once validating the plan output looks correct, you can deploy Coder:

```bash
terragrunt run-all apply
```

After `apply` succeeds, Coder will be accessible at the provided hostname. You
can login with the user `admin` and the provided password.

### Destroying

To tear down a Coder deployment, run:

```bash
terragrunt run-all destroy
```

## Support

If you experience issues, have feedback, or want to ask a question, open an
issue or pull request in this repository. Feel free to [contact us
instead](https://coder.com/contact).
