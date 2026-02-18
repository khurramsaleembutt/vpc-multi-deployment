# Fluent Bit Helm Deployment with Pod Identity
resource "kubernetes_namespace_v1" "amazon_cloudwatch" {
  count = var.enable_monitoring ? 1 : 0
  metadata {
    name = "amazon-cloudwatch"
    labels = {
      name = "amazon-cloudwatch"
    }
  }
  
  depends_on = [aws_eks_access_policy_association.sso_admin_policy, aws_eks_access_policy_association.github_actions_policy]
}

resource "kubernetes_service_account_v1" "fluent_bit" {
  count = var.enable_monitoring ? 1 : 0
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace_v1.amazon_cloudwatch[0].metadata[0].name
    # No IRSA annotations needed - using Pod Identity
  }
  
  depends_on = [aws_eks_access_policy_association.sso_admin_policy, aws_eks_access_policy_association.github_actions_policy]
}

# Fluent Bit Helm deployment with Pod Identity support
resource "helm_release" "aws_for_fluent_bit" {
  count      = var.enable_monitoring ? 1 : 0
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = kubernetes_namespace_v1.amazon_cloudwatch[0].metadata[0].name
  version    = "0.2.0"

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = kubernetes_service_account_v1.fluent_bit[0].metadata[0].name
        annotations = {}
      }
      
      # Disable IMDSv1/v2 fallback
      hostNetwork = false
      
      cloudWatchLogs = {
        enabled = true
        match = "no-match"
        region = data.aws_region.current.name
        logGroupName = "/dev/null"
        logStreamPrefix = "unused-"
        autoCreateGroup = false
      }
      
      firehose = {
        enabled = false
      }
      
      kinesis = {
        enabled = false
      }
      
      elasticsearch = {
        enabled = false
      }

      additionalOutputs = <<-EOT
        # Rewrite tags for service-specific routing
        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.auth-*_ecommerce-dev_auth-*
            Rule                $log ^.*$ ecommerce.auth false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.payment-*_ecommerce-dev_payment-*
            Rule                $log ^.*$ ecommerce.payment false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.order-*_ecommerce-dev_order-*
            Rule                $log ^.*$ ecommerce.order false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.cart-*_ecommerce-dev_cart-*
            Rule                $log ^.*$ ecommerce.cart false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.product-catalog-*_ecommerce-dev_product-catalog-*
            Rule                $log ^.*$ ecommerce.product-catalog false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.notification-*_ecommerce-dev_notification-*
            Rule                $log ^.*$ ecommerce.notification false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.admin-*_ecommerce-dev_admin-*
            Rule                $log ^.*$ ecommerce.admin false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.frontend-*_ecommerce-dev_frontend-*
            Rule                $log ^.*$ ecommerce.frontend false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.mysql-*_ecommerce-dev_mysql-*
            Rule                $log ^.*$ ecommerce.mysql false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.postgres-*_ecommerce-dev_postgres-*
            Rule                $log ^.*$ ecommerce.postgres false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.redis-*_ecommerce-dev_redis-*
            Rule                $log ^.*$ ecommerce.redis false

        [FILTER]
            Name                rewrite_tag
            Match               kube.var.log.containers.mongo-*_ecommerce-dev_mongo-*
            Rule                $log ^.*$ ecommerce.mongo false

        # Service-specific outputs
        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.auth
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/auth
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.payment
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/payment
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.order
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/order
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.cart
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/cart
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.product-catalog
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/product-catalog
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.notification
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/notification
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.admin
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/admin
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.frontend
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/frontend
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.mysql
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/mysql
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.postgres
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/postgres
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.redis
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/redis
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        [OUTPUT]
            Name                cloudwatch_logs
            Match               ecommerce.mongo
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/services/mongo
            log_stream_prefix   fluent-bit-
            auto_create_group   false

        # Fallback for system pods
        [OUTPUT]
            Name                cloudwatch_logs
            Match               kube.*
            region              ${data.aws_region.current.name}
            log_group_name      /aws/eks/${var.environment}/ecommerce/applications
            log_stream_prefix   fluent-bit-
            auto_create_group   false
      EOT
    })
  ]

  depends_on = [
    aws_eks_access_policy_association.sso_admin_policy,
    aws_eks_access_policy_association.github_actions_policy,
    aws_iam_role.fluent_bit_pod_identity_role,
    aws_iam_role_policy.fluent_bit_policy,
    aws_eks_pod_identity_association.fluent_bit,
    kubernetes_service_account_v1.fluent_bit,
    aws_cloudwatch_log_group.ecommerce_applications,
    aws_eks_node_group.node_groups
  ]
}
