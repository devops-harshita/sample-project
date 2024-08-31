data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["sample-vpc"]
  }
}

module "sample_rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.rds_name
  description = "Security group for SSH"
  vpc_id      = data.aws_vpc.vpc_id.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
data "aws_subnet" "private-subnet-a" {
  filter {
    name   = "tag:Name"
    values = ["sample-vpc-private-us-west-2a"]
  }
}
data "aws_subnet" "private-subnet-b" {
  filter {
    name   = "tag:Name"
    values = ["sample-vpc-private-us-west-2b"]
  }
}
module "db" {
  source = "terraform-aws-modules/rds/aws"

  subnet_ids = [data.aws_subnet.private-subnet-a.id,data.aws_subnet.private-subnet-b.id]
  identifier = var.rds_name

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "demodb"
  username = "user"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.sample_rds_sg.security_group_id]
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = true
}