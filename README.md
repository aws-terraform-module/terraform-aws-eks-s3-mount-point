### EKS S3 Mount Point Terraform Module (s3 volume)

You need a high volume for reading multiple large texts simultaneously. EKS S3 Mount Point is the perfect choice.

![](https://nimtechnology.com/wp-content/uploads/2025/02/image-2.png)

You can refer to [https://nimtechnology.com/2025/02/08/eks-s3-mount-point-create-a-persistent-volume-on-eks-using-an-s3-bucket/](https://nimtechnology.com/2025/02/08/eks-s3-mount-point-create-a-persistent-volume-on-eks-using-an-s3-bucket/) to understand about [S3 Mount Point](https://nimtechnology.com/2025/02/08/eks-s3-mount-point-create-a-persistent-volume-on-eks-using-an-s3-bucket/).

### Install S3 Mount Point on EKS

[eks-s3-mount-point terraform module](https://registry.terraform.io/modules/aws-terraform-module/eks-s3-mount-point/aws/latest)

#### When you install EKS cluster by Terraform Module:

```hcl
variable "aws_region" {
  description = "The AWS region where the infrastructure will be deployed. This should be the region closest to your users or where you prefer to host your resources. Example: 'us-east-1', 'eu-central-1'."
  type        = string
  default     = "eu-central-1"
}

# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "private-windows-mdaas-eks-tf-lock"
    key    = "private-windows-eks.tfstate"
    region = "us-east-1"
  }
}


module "eks-s3-mount-point" {
  source  = "aws-terraform-module/eks-s3-mount-point/aws"
  version = "0.0.6"
  aws_region = var.aws_region
  s3-bucket-name = "s3-bucket-nimtechnology"
  eks_cluster_certificate_authority_data = data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data
  eks_cluster_endpoint = data.terraform_remote_state.eks.outputs.cluster_endpoint
  eks_cluster_name = data.terraform_remote_state.eks.outputs.cluster_name
  aws_iam_openid_connect_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}
```