# IAM Role for Service Account for Load Balancer Controller
module "load_balancer_controller_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name = "${var.name}-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# Alternatively, if you want to use the custom policy created above:
resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = module.load_balancer_controller_irsa.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}