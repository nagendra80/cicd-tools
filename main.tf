module "jenkins" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"

  instance_type = "t3.small"
  vpc_security_group_ids = ["sg-024ec5f8fa4a072d9"]
  subnet_id = "subnet-05f59ca6e3314cc9e"
  ami = data.aws_ami_info.id
  user_data = file("jenkins.sh")
  tags={
    name = "jenkins"
  }

  #Define the root volume size and type
  root_block_device = [
    {
        volume_size = 50
        volume_type = "gp3"
        delete_on_termination = true
    }
  ]
}

module "jenkins_agent" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type = "t3.small"
  vpc_security_group_ids = ["sg-024ec5f8fa4a072d9"]
  subnet_id = "subnet-05f59ca6e3314cc9e"
  ami = data.aws_ami_info.id
  user_data = file("jenkins-agent.sh")
  tags={
    name = "jenkins-agent"
  }

  #Define the root volume size and type
  root_block_device = [
    {
        volume_size = 50
        volume_type = "gp3"
        delete_on_termination = true
    }
  ]
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    }
  ]

}
