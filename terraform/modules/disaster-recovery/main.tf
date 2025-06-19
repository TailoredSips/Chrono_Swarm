# DR Region VCN
resource "oci_core_vcn" "dr_vcn" {
  provider       = oci.dr_region
  compartment_id = var.compartment_ocid
  display_name   = "ChronoSwarm-DR-VCN"
  cidr_blocks    = ["10.1.0.0/16"]
  dns_label      = "chronoswarmdr"
  
  tags = var.common_tags
}

# Cross-Region Replication for Database
resource "oci_database_autonomous_database" "dr_database" {
  provider                = oci.dr_region
  compartment_id          = var.compartment_ocid
  cpu_core_count          = 1
  data_storage_size_in_tbs = 1
  db_name                 = "chronoswarmdr"
  display_name            = "ChronoSwarm-DR-Database"
  is_auto_scaling_enabled = true
  license_model           = "LICENSE_INCLUDED"
  
  # Autonomous Data Guard configuration
  is_data_guard_enabled = true
  autonomous_database_id = var.primary_database_id
  
  tags = var.common_tags
}

# Cross-Region Object Storage Replication
resource "oci_objectstorage_bucket" "dr_backup_bucket" {
  provider      = oci.dr_region
  compartment_id = var.compartment_ocid
  name          = "chrono-swarm-dr-backups"
  namespace     = var.object_storage_namespace
  
  # Replication configuration
  replication_enabled = true
  
  tags = var.common_tags
}

# Kafka MirrorMaker 2 Configuration
resource "oci_core_instance" "kafka_mirrormaker" {
  provider           = oci.dr_region
  compartment_id     = var.compartment_ocid
  display_name       = "ChronoSwarm-MirrorMaker"
  availability_domain = data.oci_identity_availability_domains.dr_ads.availability_domains[0].name
  shape              = "VM.Standard.A1.Flex"
  
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }
  
  create_vnic_details {
    subnet_id                 = oci_core_subnet.dr_private_kafka.id
    display_name              = "MirrorMaker-VNIC"
    assign_public_ip          = false
    nsg_ids                   = [oci_core_network_security_group.dr_kafka_nsg.id]
  }
  
  source_details {
    source_type = "image"
    source_id   = var.kafka_golden_image_id
  }
  
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/scripts/mirrormaker-init.sh", {
      primary_kafka_brokers = var.primary_kafka_brokers
      dr_kafka_brokers     = var.dr_kafka_brokers
    }))
  }
  
  tags = var.common_tags
}

# DR Failover Automation
resource "oci_functions_application" "dr_failover" {
  provider       = oci.dr_region
  compartment_id = var.compartment_ocid
  display_name   = "ChronoSwarm-DR-Failover"
  subnet_ids     = [oci_core_subnet.dr_private_control.id]
  
  tags = var.common_tags
}

resource "oci_functions_function" "automated_failover" {
  provider       = oci.dr_region
  application_id = oci_functions_application.dr_failover.id
  display_name   = "automated-failover"
  image         = var.failover_function_image
  memory_in_mbs = 256
  timeout_in_seconds = 300
  
  config = {
    PRIMARY_REGION     = var.primary_region
    DR_REGION         = var.dr_region
    NOTIFICATION_TOPIC = var.notification_topic_id
  }
}
