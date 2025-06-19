source "amazon-ebs" "executor-node" {
  region                  = "us-west-2"
  instance_type           = "t4g.medium"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
      root-device-type    = "ebs"
      architecture        = "arm64"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  ssh_username            = "ubuntu"
  ami_name                = "chrono-swarm-executor-node-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.executor-node"]
  provisioner "shell" {
    script = "../scripts/install-base.sh"
  }
  provisioner "shell" {
    script = "../scripts/install-docker.sh"
  }
  provisioner "shell" {
    script = "../scripts/install-monitoring.sh"
  }
  provisioner "shell" {
    script = "../scripts/security-hardening.sh"
  }
}
