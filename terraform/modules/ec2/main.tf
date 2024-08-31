data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["sample-vpc-public-us-west-2a"]
  }
}
data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["sample-vpc"]
  }
}
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = var.ec2_name

  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = [module.sample_ec2_sg.security_group_id]
  subnet_id              = data.aws_subnet.selected.id

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}

module "sample_ec2_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.ec2_name
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