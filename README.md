# Coder Terraform Modules

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

## Support

If you experience issues, have feedback, or want to ask a question, open an
issue or pull request in this repository. Feel free to [contact us
instead](https://coder.com/contact).

## Copyright and License

Copyright (C) 2021 Coder Technologies Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
