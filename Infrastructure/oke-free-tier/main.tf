resource "oci_containerengine_cluster" "generated_oci_containerengine_cluster" {
	cluster_pod_network_options {
		cni_type = "FLANNEL_OVERLAY"
	}
	compartment_id = var.Cluster_variables.compartment_id
	endpoint_config {
		is_public_ip_enabled = "true"
		subnet_id = var.Cluster_variables.subnet_id
	}
	kubernetes_version = "v1.30.1"
	name = "oke-cluster"
	options {
		kubernetes_network_config {
			pods_cidr = "10.244.0.0/16"
			services_cidr = "10.96.0.0/16"
		}
		persistent_volume_config {
		}
		service_lb_config {
		}
		service_lb_subnet_ids = var.Cluster_variables.service_lb_subnet_ids
	}
	type = "BASIC_CLUSTER"
	vcn_id = var.Cluster_variables.vcn_id
}

resource "oci_containerengine_node_pool" "create_node_pool_details0" {
	cluster_id = "${oci_containerengine_cluster.generated_oci_containerengine_cluster.id}"
	compartment_id = var.Cluster_variables.compartment_id
	initial_node_labels {
		key = "name"
		value = "node-pool"
	}
	kubernetes_version = "v1.30.1"
	name = "node-pool"
	node_config_details {
		node_pool_pod_network_option_details {
			cni_type = "FLANNEL_OVERLAY"
			max_pods_per_node = "31"
		}
		placement_configs {
			availability_domain = var.Cluster_variables.availability_domain
			subnet_id = var.Cluster_variables.node_group_subnet_id
		}
		size = "2"
	}
	node_eviction_node_pool_settings {
		eviction_grace_duration = "PT60M"
		is_force_delete_after_grace_duration = "false"
	}
	node_shape = "VM.Standard.A1.Flex"
	node_shape_config {
		memory_in_gbs = "12"
		ocpus = "2"
	}
	node_source_details {
		boot_volume_size_in_gbs = "50"
		image_id = "ocid1.image.oc1.iad.aaaaaaaa35afxc4q57i6xnd275vmtr57zjrccp3lyr26mwl4yfpx4lpb2koq"
		source_type = "IMAGE"
	}
}
