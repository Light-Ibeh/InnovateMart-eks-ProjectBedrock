# eks-cluster.tf — EKS cluster

resource "aws_eks_cluster" "this" {
  name     = "innovatemart-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # include subnets where the control plane will create ENIs
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
    ]

    endpoint_public_access = true
    # endpoint_private_access = false  # leave default unless you need private-only
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}

# Optional outputs to help with kubeconfig later
output "cluster_name" {
  value = aws_eks_cluster.this.name
}
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}
output "cluster_cert_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}