terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}



resource "aws_instance" "amzLinuxMilind" {
  ami                         = var.ami_image_id
  instance_type               = var.instance_size
  subnet_id                   = aws_subnet.DefaultVPCPublicSubnet.id
  key_name                    = var.key_name
  vpc_security_group_ids   = [aws_security_group.defaultSecurityGrp.id]
  associate_public_ip_address = true


  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname instance0.wiself.in
sudo mkdir -p /home/ec2-user/efs
sudo chown ec2-user /home/ec2-user/efs
echo 'fs-0799438a25f1315ec.efs.us-east-2.amazonaws.com:/ /home/ec2-user/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport' >>  /etc/fstab
sudo mount -a
yum install -y nginx
EOF


  connection {
    agent       = false
    host = aws_instance.amzLinuxMilind.public_ip
    user        = var.osuser
    private_key = file(var.path_to_private_key)
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"


  }


  provisioner "remote-exec" {

    inline = ["chmod +x /tmp/install.sh", "sudo /tmp/install.sh"]

  }

  tags = { "Name" = "AmazonLinuxT2"
  "ManagedBy" = "Terraform" }

}

resource "aws_security_group" "defaultSecurityGrp" {
  ingress = [
    {
      "cidr_blocks" : [
        "0.0.0.0/0"
      ],
      "description" : "",
      "from_port" : 22,
      "ipv6_cidr_blocks" : [],
      "prefix_list_ids" : [],
      "protocol" : "tcp",
      "security_groups" : [],
      "self" : false,
      "to_port" : 22
    },
    {
      "cidr_blocks" : [
        "0.0.0.0/0"
      ],
      "description" : "",
      "from_port" : 9090,
      "ipv6_cidr_blocks" : [],
      "prefix_list_ids" : [],
      "protocol" : "tcp",
      "security_groups" : [],
      "self" : false,
      "to_port" : 9090
    },
    {
      cidr_blocks = [
        "10.0.0.0/16"
      ]
      description      = ""
      from_port        = 2049
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 2049
    }
  ]
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" : "defaultSecurityGrp"
  }
  vpc_id = aws_vpc.DefaultVPC.id
}

resource "aws_vpc" "DefaultVPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "DefaultVPC"
  }

}

resource "aws_subnet" "DefaultVPCPublicSubnet" {
  vpc_id                  = aws_vpc.DefaultVPC.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true


  tags = {
    Name = "DefaultVPCPublicSubnet"
  }

}

resource "aws_subnet" "DefaultVPCPrivateSubnet" {
  vpc_id                  = aws_vpc.DefaultVPC.id
  cidr_block              = "10.0.16.0/20"
  map_public_ip_on_launch = false

  tags = {
    Name = "DefaultVPCPrivateSubnet"
  }

}


resource "aws_internet_gateway" "defaultIGW" {
  vpc_id = aws_vpc.DefaultVPC.id

  tags = {
    Name = "defaultIGW"
  }
}

resource "aws_route_table" "public_route1" {
  vpc_id = aws_vpc.DefaultVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.defaultIGW.id
  }

  tags = { "Name" : "public_route1" }
}

