variable "aws_region" {
  description = "The AWS region where the infrastructure will be deployed. This should be the region closest to your users or where you prefer to host your resources. Example: 'us-east-1', 'eu-central-1'."
  type        = string
  default     = "eu-central-1"
}

variable "s3-bucket-name" {
  description = "The unique name for the S3 bucket used to store data in AWS. This name must be globally unique across all AWS accounts. Example: 'my-unique-s3-bucket-123'."
  type        = string
  default     = "s3-bucket-nimtechnology"
}

variable "extra_tags" {
  description = "A map of additional tags to assign to the S3 bucket. This allows users to add custom tags to the bucket."
  type        = map(string)
  default     = {}  # Default is an empty map if no extra tags are provided
}

variable "aws_iam_openid_connect_provider_arn" {
  description = "The ARN assigned by AWS for this provider/data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn. Example: 'arn:aws:iam::31XXXX0340:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/131E65299AXXXXXX84049A0'"
  type = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:oidc-provider/", var.aws_iam_openid_connect_provider_arn))
    error_message = "The OIDC provider ARN must be valid and start with 'arn:aws:iam::' followed by the account ID and ':oidc-provider/'."
  }
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  type = string
  validation {
    condition     = length(var.eks_cluster_name) > 0
    error_message = "EKS cluster name must be provided."
  }
}

variable "eks_cluster_endpoint" {
  description = "The hostname (in form of URI) of Kubernetes master/data.terraform_remote_state.eks.outputs.cluster_endpoint"
  type = string
  validation {
    condition     = can(regex("^https://", var.eks_cluster_endpoint))
    error_message = "The cluster endpoint must be a valid HTTPS URL."
  }
}

variable "eks_cluster_certificate_authority_data" {
  description = "PEM-encoded root certificates bundle for TLS authentication./data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data"
  type = string
  validation {
    condition     = can(base64decode(var.eks_cluster_certificate_authority_data))
    error_message = "The certificate authority data must be base64 encoded."
  }
}