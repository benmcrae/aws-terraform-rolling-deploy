# AWS Rolling deploys with Terraform

Rolling deploys behind an AWS Elastic Load Balancer (ELB), using [Terraform](https://www.terraform.io/).

Two individual (versioned) AMIs, using Auto Scaling Groups and Launch Configurations to simulating a Blue / Green deployment.

This demo is built upon [mod-network](https://github.com/benmcrae/mod-network), leaving us with only 2 essential Terraform files `app-asg.tf` and `app-elb.tf`.

This workflow has been heavily influenced by [Rob Morgan's](https://robmorgan.id.au/posts/rolling-deploys-on-aws-using-terraform/) blog post.

## Setup (AMI Builds)

We will build our AMIs using [Packer](https://www.packer.io/). Within the root directory of our repository, run...

```
packer build packer/v1-blue.json
```

Once the build has complete, the log output will print the created AMI identifier. *Be sure to keep a record for later use!*

```
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:

eu-west-1: ami-53941a20
```

Repeat the same steps for the `v2-green.json` packer file.

## Create Infrastructure

Within the project root directory, we need to download the module dependencies.

```
terraform get
```

Now we are able to plan and apply our infrastructure.

*This assumes you have the `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` in your environment variables.*

We need to substitute the `-var "ami_id=ami-********"` with the correct AMI ID from `v1-blue.json`.

```
terraform plan -var "ami_id=ami-53941a20"
terraform apply -var "ami_id=ami-53941a20
```

The output of the terraform run will give you an ELB DNS address. Browsing to this address should display the `V1-BLUE` homepage.

## Rolling Deploy

Now we want to upgrade our application to `V2-GREEN`.

Just substitute the `-var "ami_id=ami-********"` with the correct AMI ID from `v2-green.json`.

Run our plan first, then apply...

```
terraform plan -var "ami_id=ami-6ef0781d"
terraform apply -var "ami_id=ami-6ef0781d
```

Voilà!

### Testing the zero downtime rolling deploy

Before running the rolling deploy, execute the below command in a separate terminal window. This will poll the ELB every 1 millisecond for the current application version.

Over time we will see the app swap from `V1-BLUE` to `V2-GREEN`.

```
while true; do curl -s app.eu-west-1.elb.amazonaws.com | sed -e 's,.*<h1>\([^<]*\)</h1>.*,\1,g'; sleep .1; done
```

*Ensure you change 'app.eu-west-1.elb.amazonaws.com' to the correct ELB address of your application.*

## Tear down

For good hygiene, lets destroy the infrastructure we created once finished.

```
terraform destroy
```
