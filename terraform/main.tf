terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true


}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_1
  availability_zone = var.az_1
  map_public_ip_on_launch = true

  tags = {
    name = "pub_sub1"
  }
}
resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_2
  availability_zone = var.az_2
  map_public_ip_on_launch = true

  tags = {
    name = "pub_sub2"
  }
}



resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table_association" "pub_RT1_assoc" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "pub_RT2_assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.public_2.id
}

# variables (top of file)
variable "environment" {
  default = "dev"
}

resource "aws_iam_role" "eks_cluster_role_3" {
  name = "eks-cluster-role-${var.environment}"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "iam_cluster"
  }
}

resource "aws_iam_role_policy_attachment" "iam_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role_3.name
}

resource "aws_iam_role" "eks_worker_node_3" {
  name = "eks-worker-role-${var.environment}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "node-value"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node_3.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node_3.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node_3.name
}


resource "aws_security_group" "eks_cluster_security_group" {
  name ="eks_cluster_sg"
  description = "Allow traffic to eks node"
  vpc_id = aws_vpc.main.id
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "eks_node_sg" {
  name ="EKS_node_sg "
  description = "security group for eks worker node"
  vpc_id = aws_vpc.main.id

     ingress {
       from_port = 0
       to_port = 0
       protocol = "-1"
       self = true
     }

     egress {
       to_port = 0
       from_port = 0
       protocol = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }

}
resource "aws_eks_cluster" "eks_cluster" {
  name = "Eks_cluster"

  access_config {
  authentication_mode                         = "API_AND_CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true
}

  role_arn = aws_iam_role.eks_cluster_role_3.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [
     aws_subnet.public_1.id,
      aws_subnet.public_2.id,
     

    ]
    security_group_ids = [aws_security_group.eks_cluster_security_group.id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.iam_cluster_policy,
  ]
}
resource "aws_eks_node_group" "eks_node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "Worker_node"
  node_role_arn   = aws_iam_role.eks_worker_node_3.arn
  subnet_ids      = [
 aws_subnet.public_1.id,
      aws_subnet.public_2.id,
  ]
instance_types = [var.Node_Instance_type]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
