resource "aws_elb" "app" {
  name = "app"
  subnets = ["${split(",", module.network.public_subnet_ids)}"]
  security_groups = ["${aws_security_group.elb_allow_all.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "app.${var.tag_environment}"
    Project = "${var.tag_project}"
    Environment = "${var.tag_environment}"
  }
}

resource "aws_security_group" "elb_allow_all" {
  name = "elb_allow_all"
  vpc_id = "${module.network.vpc_id}"
  description = "Allow all inbound traffic"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = ["${aws_security_group.allow_all.id}"]
  }

  tags {
    Name = "elb-app.${var.tag_environment}"
    Project = "${var.tag_project}"
    Environment = "${var.tag_project}"
  }
}

output "elb" {
  value = "${aws_elb.app.dns_name}"
}
