# CloudWatch Metric Filters and Alarms for EcommerceApp
resource "aws_cloudwatch_log_metric_filter" "ecommerce_errors" {
  for_each = var.enable_monitoring ? toset([
    "auth", "product-catalog", "cart", "order", 
    "payment", "notification", "admin",
    "mysql", "postgres", "redis", "mongo"
  ]) : toset([])

  name           = "${var.environment}-ecommerce-${each.key}-errors"
  log_group_name = aws_cloudwatch_log_group.ecommerce_services[each.key].name
  pattern        = "{ $.data.level = \"ERROR\" }"

  metric_transformation {
    name      = "EcommerceErrorCount"
    namespace = "EKS/Ecommerce/${title(each.key)}"
    value     = "1"
    default_value = "0"
  }
}

# Payment service critical monitoring
resource "aws_cloudwatch_log_metric_filter" "payment_failures" {
  count          = var.enable_monitoring ? 1 : 0
  name           = "${var.environment}-ecommerce-payment-failures"
  log_group_name = aws_cloudwatch_log_group.ecommerce_services["payment"].name
  pattern        = "{ $.message = \"*payment*failed*\" || $.message = \"*stripe*error*\" || $.message = \"*charge*failed*\" }"

  metric_transformation {
    name      = "PaymentFailureCount"
    namespace = "EKS/Ecommerce/Payment"
    value     = "1"
  }
}

# General application exceptions
resource "aws_cloudwatch_log_metric_filter" "ecommerce_exceptions" {
  for_each = var.enable_monitoring ? toset([
    "auth", "product-catalog", "cart", "order", 
    "payment", "notification", "admin"
  ]) : toset([])

  name           = "${var.environment}-ecommerce-${each.key}-exceptions"
  log_group_name = aws_cloudwatch_log_group.ecommerce_services[each.key].name
  pattern        = "Exception"

  metric_transformation {
    name      = "EcommerceExceptionCount"
    namespace = "EKS/Ecommerce/${title(each.key)}"
    value     = "1"
    default_value = "0"
  }
}

# Use existing SNS topic for alerts
data "aws_sns_topic" "email_alerts" {
  count = var.enable_monitoring ? 1 : 0
  name = "MyEmailTopic"
}

# High error rate alarms
resource "aws_cloudwatch_metric_alarm" "ecommerce_high_errors" {
  for_each = var.enable_monitoring ? toset(["auth", "payment", "order"]) : toset([])

  alarm_name          = "${var.environment}-ecommerce-${each.key}-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "EcommerceErrorCount"
  namespace           = "EKS/Ecommerce/${title(each.key)}"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "High error rate in ${each.key} service"
  alarm_actions       = [data.aws_sns_topic.email_alerts[0].arn]

  tags = merge(var.tags, {
    Service   = each.key
    Component = "monitoring"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "ecommerce_dashboard" {
  count          = var.enable_monitoring ? 1 : 0
  dashboard_name = "${var.environment}-ecommerce-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["EKS/Ecommerce/Auth", "EcommerceErrorCount"],
            ["EKS/Ecommerce/Order", "EcommerceErrorCount"],
            ["EKS/Ecommerce/Payment", "EcommerceErrorCount"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Error Count by Service"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["EKS/Ecommerce/Auth", "EcommerceErrorCount"],
            ["EKS/Ecommerce/Order", "EcommerceErrorCount"],
            ["EKS/Ecommerce/Payment", "EcommerceErrorCount"]
          ]
          view   = "singleValue"
          region = data.aws_region.current.name
          title  = "Current Error Rate (5-min period)"
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["EKS/Ecommerce/Auth", "EcommerceErrorCount"],
            ["EKS/Ecommerce/Order", "EcommerceErrorCount"],
            ["EKS/Ecommerce/Payment", "EcommerceErrorCount"]
          ]
          view    = "timeSeries"
          stacked = true
          region  = data.aws_region.current.name
          title   = "Stacked Error Count - All Services"
          period  = 300
          stat    = "Sum"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          query   = "SOURCE '/aws/eks/${var.environment}/ecommerce/services/auth'\n| fields @timestamp, data.level, data.service, data.message, data.function, data.line\n| filter data.level = \"ERROR\"\n| sort @timestamp desc\n| limit 20"
          region  = data.aws_region.current.name
          title   = "Recent Auth Service Errors (Structured Logs)"
          view    = "table"
        }
      }
    ]
  })
}
