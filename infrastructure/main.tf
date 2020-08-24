variable "name" { default = "guide" }
variable "nookbook_vpc_id" { default = "vpc-0dc86c5a01fcfc699" }

provider "aws" { region = "us-east-2" }

resource "aws_security_group" "nookbook" {
  name   = "${var.name}-nookbook-application"
  vpc_id = var.nookbook_vpc_id
}
