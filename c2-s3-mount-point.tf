resource "aws_s3_bucket" "s3_mount_point" {
  bucket = "${var.s3-bucket-name}"  # Replace with a unique bucket name

  tags = merge(
    {
      Name = var.s3-bucket-name
    },
    var.extra_tags  # Merge the extra tags here
  )
}

# Resource: Create S3 Mount Point CSI IAM Policy
resource "aws_iam_policy" "mountpoint_s3_csi_iam_policy" {
  name        = "${var.s3-bucket-name}_AmazonEKS_S3_Mount_Point_CSI_Driver_Policy"
  path        = "/"
  description = "Create S3 Mount Point CSI IAM Policy"
  policy = jsonencode({
   "Version": "2012-10-17",
   "Statement": [
        {
            "Sid": "MountpointFullBucketAccess",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3-bucket-name}"
            ]
        },
        {
            "Sid": "MountpointFullObjectAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3-bucket-name}/*"
            ]
        }
   ]
})
    tags = merge(
    {
      Name = "${var.s3-bucket-name}_AmazonEKS_S3_Mount_Point_CSI_Driver_Policy"
    },
    var.extra_tags  # Merge the extra tags here
    )

}

# Resource: Create IAM Role and associate the S3 Mount Point IAM Policy to it
resource "aws_iam_role" "mountpoint_s3_csi_iam_role" {
  name = "${var.s3-bucket-name}-mountpoint-s3-csi-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${var.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_openid_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:s3-csi-driver-sa"
          }
        }
      },
    ]
  })

  tags = merge(
    {
      Name = "${var.s3-bucket-name}-mountpoint-s3-csi-iam-role"
    },
    var.extra_tags  # Merge the extra tags here
    )
}

# Associate S3 Mount Point CSI IAM Policy to S3 Mount Point CSI IAM Role
resource "aws_iam_role_policy_attachment" "mountpoint_s3_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.mountpoint_s3_csi_iam_policy.arn
  role       = aws_iam_role.mountpoint_s3_csi_iam_role.name
}

output "mountpoint_s3_csi_iam_role_arn" {
  description = "S3 Mount Point CSI IAM Role ARN"
  value = aws_iam_role.mountpoint_s3_csi_iam_role.arn
}