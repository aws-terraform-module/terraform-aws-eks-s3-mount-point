# Data source to list all node groups in the cluster
data "aws_eks_node_groups" "all" {
  cluster_name = var.eks_cluster_name
}

# Loop through each node group to retrieve its details
data "aws_eks_node_group" "details" {
  for_each     = toset(data.aws_eks_node_groups.all.names)
  cluster_name = var.eks_cluster_name
  node_group_name = each.key
}

# Attach the AmazonS3FullAccess policy to each node group's IAM role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  for_each   = data.aws_eks_node_group.details
  role       = split("/", each.value.node_role_arn)[1]  # Extracting the role name from the ARN
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}