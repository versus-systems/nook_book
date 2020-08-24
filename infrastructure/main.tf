variable "name" { default = "guide" }
variable "nookbook_vpc_id" { default = "vpc-0dc86c5a01fcfc699" }

provider "aws" { region = "us-east-2" }

resource "aws_security_group" "nookbook" {
  name   = "${var.name}-nookbook-application"
  vpc_id = var.nookbook_vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 4000
    to_port     = 4000
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 4369
    to_port     = 4369
    cidr_blocks = ["10.0.0.0/16"]
    description = "Default EPMD port"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 20000
    to_port     = 20099
    cidr_blocks = ["10.0.1.0/24"]
    description = "EPMD post connect mapping"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
