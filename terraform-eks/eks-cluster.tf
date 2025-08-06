module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  name               = "${var.name}-2025"
  kubernetes_version = "1.33"
  endpoint_public_access = true

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"

      min_size = 2
      max_size = 5
      desired_size = 2
    }
  }

  tags = local.tags
}