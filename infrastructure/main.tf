variable "name" { default = "guide" }
variable "nookbook_vpc_id" { default = "vpc-0dc86c5a01fcfc699" }
variable "nookbook_alb_listener" {
  default = "arn:aws:elasticloadbalancing:us-east-2:797420293962:listener/app/app-alb/06ba40177a02a85d/8970cd65f589522b"
}
variable "nookbook_private_subnet" { default = "subnet-00deae77515e96e8c" }

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

resource "aws_lb_target_group" "nookbook_group" {
  name     = "${var.name}-nookbook-target"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = var.nookbook_vpc_id
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = var.nookbook_alb_listener

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nookbook_group.arn
  }

  condition {
    host_header {
      values = ["${var.name}.nookbook.online"]
    }
  }
}

resource "aws_instance" "nookbook1" {
  instance_type          = "t2.micro"
  ami                    = "ami-016b213e65284e9c9"
  vpc_security_group_ids = ["${aws_security_group.nookbook.id}"]
  subnet_id              = var.nookbook_private_subnet
  tags = {
    Name = "${var.name}-instance-1"
  }
}

resource "aws_instance" "nookbook2" {
  instance_type          = "t2.micro"
  ami                    = "ami-016b213e65284e9c9"
  vpc_security_group_ids = ["${aws_security_group.nookbook.id}"]
  subnet_id              = var.nookbook_private_subnet
  tags = {
    Name = "${var.name}-instance-2"
  }
}

resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_lb_target_group.nookbook_group.arn
  target_id        = aws_instance.nookbook1.id
  port             = 4000
}

resource "aws_lb_target_group_attachment" "attachment2" {
  target_group_arn = aws_lb_target_group.nookbook_group.arn
  target_id        = aws_instance.nookbook2.id
  port             = 4000
}
