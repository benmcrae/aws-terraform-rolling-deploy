module "network" {
  source = "github.com/benmcrae/mod-network?ref=v0.2.0"
  tag_project = "${var.tag_project}"
  tag_environment = "${var.tag_environment}"
}
