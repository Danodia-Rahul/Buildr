##########################
##        INSTANCE      ##
##########################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "buldr_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids      = [aws_security_group.buildr_sg.id]
  depends_on = [
    aws_iam_instance_profile.ec2_profile,
    aws_iam_role_policy_attachment.ssm_core
  ]
  tags = {
    Name = "buildr_ec2"
  }
}

##########################
##     SECURITY GROUP   ##
##########################

resource "aws_security_group" "buildr_sg" {
  name   = "buildr_security_group"
  vpc_id = aws_vpc.buildr_vpc.id
  tags = {
    Name = "buildr_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_sg" {
  security_group_id = aws_security_group.buildr_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8000
  to_port           = 8000
}

resource "aws_vpc_security_group_egress_rule" "egress_sg" {
  security_group_id = aws_security_group.buildr_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


##########################
##    SESSION MANAGER   ##
##########################

resource "aws_iam_role" "buildr_ssm_role" {
  name = "buildr-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.buildr_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.buildr_ssm_role.name
}
