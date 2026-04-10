resource "aws_security_group" "alb_sg" {
  name        = "devops-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-alb-sg"
  }
}

resource "aws_lb" "devops_alb" {
  name               = "devops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "devops-alb"
  }
}
resource "aws_lb_target_group" "devops_tg" {
  name     = "devops-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.devops_vpc.id
  target_type = "instance"
  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
  tags = {
    Name = "devops-tg"
  }
}
resource "aws_lb_target_group_attachment" "devops_tg_attach" {
  count            = 2
  target_group_arn = aws_lb_target_group.devops_tg.arn
  #target_id        = aws_instance.devops_demo_ec2.id #Single EC2 instance
  target_id        = aws_instance.devops_demo_ec2[count.index].id
  port             = 8080
}
resource "aws_lb_listener" "devops_listener" {
  load_balancer_arn = aws_lb.devops_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devops_tg.arn
  }
}

output "devops_alb_dns" {
  value = aws_lb.devops_alb.dns_name
}