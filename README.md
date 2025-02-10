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

### Create PVC and PV

S3 volume is the static provisioning volume.  
Create a PVC and PV before mounting to the pod.  
(Please ignore capacity.storage in `PersistentVolume` and `requests`.`storage` in `PersistentVolumeClaim`  , AND Don't remove them.)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: s3-pv
spec:
  capacity:
    storage: 1200Gi # ignored, required
  accessModes:
    - ReadWriteMany 
  storageClassName: "" # Required for static provisioning
  claimRef: # To ensure no other PVCs can claim this PV
    namespace: default # Namespace is required even though it's in "default" namespace.
    name: s3-pvc # Name of your PVC
  mountOptions:
    - allow-delete # If you want to allow file deletion, use the --allow-delete flag at mount time. Delete operations immediately delete the object from S3, even if the file is being read from.
    - region eu-central-1 # The AWS region where the bucket is located.
    - uid=100
    - gid=101
    - dir-mode=0777
    - file-mode=0777
    - allow-other
    - allow-overwrite
  csi:
    driver: s3.csi.aws.com # required
    volumeHandle: s3-bucket-nimtechnology-volume 
    volumeAttributes:
      bucketName: s3-bucket-nimtechnology # The name of the S3 bucket.
      #authenticationSource: pod # To configure the Mountpoint CSI Driver to use Pod-Level Credentials, configure your PV using authenticationSource: pod in the volumeAttributes section
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: s3-pvc
spec:
  accessModes:
    - ReadWriteMany # Supported options: ReadWriteMany / ReadOnlyMany
  storageClassName: "" # Required for static provisioning
  resources:
    requests:
      storage: 1200Gi # Ignored, required
  volumeName: s3-pv # Name of your PV
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: s3-app
  labels:
    app: s3-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: s3-app
  template:
    metadata:
      labels:
        app: s3-app
    spec:
      containers:
      - name: s3-app
        image: centos
        command: ["/bin/sh"]
        args: ["-c", "echo 'Hello from the container!' >> /data/$(date -u).txt; tail -f /dev/null"]
        volumeMounts:
        - name: persistent-storage
          mountPath: /data
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/os: linux
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: s3-pvc
```