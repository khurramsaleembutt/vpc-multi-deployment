# CloudWatch Log Groups for EcommerceApp
resource "aws_cloudwatch_log_group" "ecommerce_applications" {
  count             = var.enable_monitoring ? 1 : 0
  name              = "/aws/eks/${var.environment}/ecommerce/applications"
  retention_in_days = 7
  
  tags = merge(var.tags, {
    Application = "ecommerce"
    Component   = "logging"
  })
}

# Service-specific log groups
resource "aws_cloudwatch_log_group" "ecommerce_services" {
  for_each = var.enable_monitoring ? toset([
    "auth", "product-catalog", "cart", "order", 
    "payment", "notification", "admin", "frontend",
    "mysql", "postgres", "redis", "mongo"  # Database services
  ]) : toset([])
  
  name              = "/aws/eks/${var.environment}/ecommerce/services/${each.key}"
  retention_in_days = 7
  
  tags = merge(var.tags, {
    Application = "ecommerce"
    Service     = each.key
    Component   = "logging"
  })
}
