# Fluent Bit IAM Role for Pod Identity
resource "aws_iam_role" "fluent_bit_pod_identity_role" {
  count = var.enable_monitoring ? 1 : 0
  name  = "${var.environment}-fluent-bit-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Component = "logging"
  })
}

resource "aws_iam_role_policy" "fluent_bit_policy" {
  count = var.enable_monitoring ? 1 : 0
  name  = "${var.environment}-fluent-bit-policy"
  role  = aws_iam_role.fluent_bit_pod_identity_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.environment}/ecommerce/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Pod Identity Association for Fluent Bit
resource "aws_eks_pod_identity_association" "fluent_bit" {
  count           = var.enable_monitoring ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = kubernetes_namespace_v1.amazon_cloudwatch[0].metadata[0].name
  service_account = kubernetes_service_account_v1.fluent_bit[0].metadata[0].name
  role_arn        = aws_iam_role.fluent_bit_pod_identity_role[0].arn

  depends_on = [
    aws_eks_addon.addons
  ]

  tags = merge(var.tags, {
    Component = "logging"
  })
}
