# Install EFS CSI Driver using HELM

# Resource: Helm Release 
resource "helm_release" "aws-mountpoint-s3-csi-driver" {
  depends_on = [aws_iam_role.mountpoint_s3_csi_iam_role]            
  name       = "aws-mountpoint-s3-csi-driver"

  repository = "https://awslabs.github.io/mountpoint-s3-csi-driver"
  chart      = "aws-mountpoint-s3-csi-driver"

  namespace = "kube-system"     

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.mountpoint_s3_csi_iam_role.arn}"
  }
    
}