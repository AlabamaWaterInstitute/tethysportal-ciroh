CIROH Portal Deployment on AWS
==============================

Prerequisites
-------------
- AWS Client (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS access to specific account/profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Variables (terraform.tfvars) Template
-------------------------------------

```yaml
region = "aws_region"
profile = "aws_profile"
cluster_name = "tethysportal-ciroh"
app_name = "tethysportal"
helm_chart = "./helm_package.tgz"  # add helm package to working directory
helm_values_file = "./values.yaml"  # add custom values.yaml to working directory
```
or

```yaml
region = "aws_region"
profile = "aws_profile"
cluster_name = "tethysportal-ciroh"
app_name = "tethysportal"
helm_chart = "chart_name"
helm_repo = "url_to_helm_repo"
helm_values_file = "./values.yaml"  # add custom values.yaml to working directory
```

How to Run
----------

The Helm provider depends on the eks module. To account for this run `terraform apply -target module.eks` so only the eks cluster and its dependencies are created. After the eks cluster is succesfully created, and in any subsequent update, run `terraform apply` normally.

Configure kubectl
-----------------

`aws eks update-kubeconfig --name <cluster_name> --region <region> --profile <profile>`

Specify kubeconfig for Terraform
--------------------------------

- Unix: KUBE_CONFIG_PATH=/path/to/kubeconfig
- Powershell: $Env:KUBE_CONFIG_PATH=/path/to/kubeconfig