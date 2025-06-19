# Virtual Cloud Network with DNS resolution
resource "oci_core_vcn" "chrono_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "ChronoSwarm-VCN"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "chronoswarm"
  
  tags = var.common_tags
}

# Internet Gateway for public subnet access
resource "oci_core_internet_gateway" "chrono_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.chrono_vcn.id
  display_name   = "ChronoSwarm-IGW"
  enabled        = true
  
  tags = var.common_tags
}

# NAT Gateway for private subnet internet access
resource "oci_core_nat_gateway" "chrono_nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.chrono_vcn.id
  display_name   = "ChronoSwarm-NAT"
  
  tags = var.common_tags
}

# Service Gateway for OCI services access
resource "oci_core_service_gateway" "chrono_sg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.chrono_vcn.id
  display_name   = "ChronoSwarm-ServiceGW"
  
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
  
  tags = var.common_tags
}
