# CIROH Portal Deployment on AWS

## Prerequisites

- AWS Client (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS access to specific account/profile (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Variables (terraform.tfvars) Template

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
helm_values_file = "./values.yaml" # add custom values.yaml to working directory
```

## How to Run

The Helm provider depends on the eks module. To account for this run `terraform apply -target module.eks` so only the eks cluster and its dependencies are created. After the eks cluster is succesfully created, and in any subsequent update, run `terraform apply` normally.

## Configure kubectl

`aws eks update-kubeconfig --name <cluster_name> --region <region> --profile <profile>`

## Specify kubeconfig for Terraform

- Unix: KUBE_CONFIG_PATH=/path/to/kubeconfig
- Powershell: $Env:KUBE_CONFIG_PATH=/path/to/kubeconfig

## TroubleShooting

- When the `terraform destroy` command does not work in one run, it can be du to a couple of reasons:
  - The ALB ingress gets destroy before, so the ingresses of the Tethys portal do nto get deleted. You might need to delete them in the AWS dashboard --> EC2--> Load Balancers
  - The VPC cannot be deleted, This is also realted to the ALB ingress being deleted before (leaving the ingresses of the Tethys Portal hanging around after the creation) As a result, the VPC is still being used by these Load Balancers. Delete the Load Balancers, and then the VPC in the AWS dashboard
- Deleting manually can sometimes cause the following error:
  - `Kubernetes cluster unreachable: invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable`
  - The following [Github Issue Comment](https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234#issuecomment-894998800) is helpful
  - The following [Medium Article](https://itnext.io/terraform-dont-use-kubernetes-provider-with-your-cluster-resource-d8ec5319d14a) is helpful as well
