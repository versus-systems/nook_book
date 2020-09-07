provider "aws" { region = "us-east-2" }

resource "aws_vpc" "nookbook" { cidr_block = "10.0.0.0/16" }
resource "aws_internet_gateway" "nookbook" { vpc_id = aws_vpc.nookbook.id }

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.nookbook.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nookbook.id
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.nookbook.id
  availability_zone = "us-east-2a"
  cidr_block        = "10.0.0.0/24"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.nookbook.id
  availability_zone = "us-east-2c"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_eip" "nat" { vpc = true }

resource "aws_nat_gateway" "nookbook" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "private_routes" {
  vpc_id = aws_vpc.nookbook.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nookbook.id
  }
}

resource "aws_route_table_association" "private_route_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_routes.id
}

resource "aws_security_group" "alb" {
  name   = "alb-security-group"
  vpc_id = aws_vpc.nookbook.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [aws_vpc.nookbook.cidr_block]
  }
}

resource "aws_lb" "nookbook" {
  name            = "app-alb"
  subnets         = [aws_subnet.public.id, aws_subnet.private.id]
  security_groups = [aws_security_group.alb.id]
}

resource "aws_route53_zone" "nookbook" { name = "nookbook.online" }

resource "aws_route53_record" "nookbook_cname" {
  zone_id = aws_route53_zone.nookbook.id
  name    = "*.nookbook.online"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.nookbook.dns_name]
}

resource "aws_security_group" "bastion" {
  name   = "bastion-security-group"
  vpc_id = aws_vpc.nookbook.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [aws_subnet.private.cidr_block]
  }
}

resource "aws_security_group" "instance" {
  name   = "instance-security-group"
  vpc_id = aws_vpc.nookbook.id

  ingress {
    protocol    = "tcp"
    from_port   = 4000
    to_port     = 4000
    cidr_blocks = [aws_vpc.nookbook.cidr_block]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [aws_subnet.public.cidr_block]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-016b213e65284e9c9"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]
}

resource "aws_instance" "fallback" {
  ami                    = "ami-016b213e65284e9c9"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.instance.id]
}

resource "aws_lb_target_group" "fallback" {
  name     = "fallback-target"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.nookbook.id
}

resource "aws_lb_listener" "nookbook" {
  load_balancer_arn = aws_lb.nookbook.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.fallback.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_lb_target_group.fallback.arn
  target_id        = aws_instance.fallback.id
  port             = 4000
}
