resource "aws_autoscaling_group" "app" {
  lifecycle { create_before_destroy = true }

  name = "app-${aws_launch_configuration.app.name}"
  load_balancers = ["${aws_elb.app.name}"]
  vpc_zone_identifier = ["${split(",", module.network.public_subnet_ids)}"]
  min_size = 1
  max_size = 1
  desired_capacity = 1
  min_elb_capacity = 1

  launch_configuration = "${aws_launch_configuration.app.name}"

  tag {
    key = "Name"
    value = "app.${var.tag_environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Project"
    value = "${var.tag_project}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.tag_environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "app" {
  lifecycle { create_before_destroy = true }

  image_id = "${var.ami_id}"
  instance_type = "t2.nano"
  security_groups = ["${aws_security_group.allow_all.id}"]
  key_name = "dev"
}

resource "aws_security_group" "allow_all" {
  name = "allow_all"
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
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "app.${var.tag_environment}"
    Project = "${var.tag_project}"
    Environment = "${var.tag_project}"
  }
}
