packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment"
}

variable "subnet_ocid" {
  type        = string
  description = "OCID of the subnet for image building"
}

variable "base_image_ocid" {
  type        = string
  description = "OCID of the base Oracle Linux image"
}

source "oracle-oci" "control-node" {
  availability_domain = "AD-1"
  base_image_ocid     = var.base_image_ocid
  compartment_ocid    = var.compartment_ocid
  subnet_ocid         = var.subnet_ocid
  
  image_name = "chrono-swarm-control-node-{{timestamp}}"
  shape      = "VM.Standard.A1.Flex"
  
  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }
  
  ssh_username = "opc"
}

build {
  name = "chrono-swarm-control-node"
  sources = ["source.oracle-oci.control-node"]
  
  # Base system hardening
  provisioner "shell" {
    script = "scripts/install-base.sh"
  }
  
  # Install Docker with security hardening
  provisioner "shell" {
    script = "scripts/install-docker.sh"
  }
  
  # Install monitoring agents
  provisioner "shell" {
    script = "scripts/install-monitoring.sh"
  }
  
  # Security hardening
  provisioner "shell" {
    script = "scripts/security-hardening.sh"
  }
  
  # Install Chrono-Swarm specific dependencies
  provisioner "shell" {
    inline = [
      "sudo dnf install -y gcc make cmake pkgconfig openssl-devel",
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
      "source ~/.cargo/env",
      "rustup target add aarch64-unknown-linux-gnu"
    ]
  }
  
  # Vulnerability scanning
  post-processor "shell-local" {
    inline = [
      "echo 'Running vulnerability scan on image...'",
      "oci vulnerability-scanning image-scan create --compartment-id ${var.compartment_ocid} --image-id ${build.ImageOCID}"
    ]
  }
}
