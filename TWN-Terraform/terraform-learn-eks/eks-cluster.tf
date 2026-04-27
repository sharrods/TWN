module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.17.1"

  name                                     = "myapp-eks-cluster"
  kubernetes_version                       = "1.33"
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id     = module.myapp-vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size       = 1
      max_size       = 3
      desired_size   = 3
      instance_types = ["t3.small"]
    }
  }
}
