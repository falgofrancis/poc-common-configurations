# AWS resources associated with the Kubecost secondary.

# This allows the k8s serviceaccount to assume the IAM role. The role gets attached to a policy which allows read/write access to the Kubecost federated storage bucket.
resource "aws_iam_role" "kubecost_federated_storage_secondary" {
  count = var.primary_cluster ? 0 : 1
  name  = "kubecost_federated_storage-s3-${var.cluster_id}"

  assume_role_policy = templatefile("${path.module}/irsa-trust.tmpl", {
    account_id      = data.aws_caller_identity.current.account_id,
    oidc            = replace(data.aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer, "https://", "")
    namespace       = var.namespace
    service-account = "${var.kubecost_helm_release_name}-cost-analyzer"
  })

  tags = var.tags
}

resource "aws_iam_policy" "kubecost_federated_storage_secondary" {
  count = var.primary_cluster ? 0 : 1
  name  = "kubecost_federated_storage-s3-policy-${var.cluster_id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.federated_storage_bucket}/*",
                "arn:aws:s3:::${var.federated_storage_bucket}"
            ]
        }
    ]
}
POLICY
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "kubecost_federated_storage_secondary" {
  count      = var.primary_cluster ? 0 : 1
  role       = aws_iam_role.kubecost_federated_storage_secondary[count.index].name
  policy_arn = aws_iam_policy.kubecost_federated_storage_secondary[count.index].arn
}