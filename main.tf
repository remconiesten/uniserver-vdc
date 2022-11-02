/*\
 * Make sure to configure terraform.tfvars
 * Note the OVA referenced there
\*/

// Pull data for edge appliance to use
data "vcd_edgegateway" "my-edge-gw" {
  name = var.vcd_edgegateway
}

// Create new routed network
resource "vcd_network_routed_v2" "my-webdmz" {
  description     = "WebDMZ (Terraform managed, do not delete)"
  name            = "WebDMZ"
  edge_gateway_id = data.vcd_edgegateway.my-edge-gw.id
  gateway         = var.webdmz_gateway
  prefix_length   = 24
  static_ip_pool {
    start_address = var.webdmz_staticippool_start
    end_address   = var.webdmz_staticippool_end
  }
  dns1 = var.dns1
  dns2 = var.dns2
}

// Create source NAT rule
resource "vcd_nsxv_snat" "webdmz-snat" {
  description        = "WebDMZ SNAT (Terraform managed, do not delete)"
  edge_gateway       = var.vcd_edgegateway
  network_type       = "ext"
  network_name       = one(data.vcd_edgegateway.my-edge-gw.external_network[*].name)
  original_address   = var.webdmz_cidr
  translated_address = data.vcd_edgegateway.my-edge-gw.external_network_ips[0]
}

// (multiple) Firewall rules, defined in fwrules.tf
resource "vcd_nsxv_firewall_rule" "fwrule" {
  edge_gateway = var.vcd_edgegateway
  for_each     = local.fwrules
  name         = each.value.description
  source {
    ip_addresses = each.value.src_cidr
  }
  destination {
    ip_addresses = each.value.dst_cidr
  }
  service {
    protocol = each.value.protocol
    port     = each.value.dst_port
  }
}

// Create empty catalog
resource "vcd_catalog" "my-catalog" {
  org              = var.org_name
  name             = "Terraform Managed Catalog"
  delete_recursive = true
  delete_force     = true
}

// Upload OVA to new catalog
resource "vcd_catalog_item" "photon-os-ova" {
  catalog              = vcd_catalog.my-catalog.name
  name                 = "Photon OS OVA"
  ova_path             = var.ova_image
  show_upload_progress = true
}

// Create empty vApp
resource "vcd_vapp" "my-vapp" {
  name = "TF-vApp"
}

// Make ORG network available in vApp
resource "vcd_vapp_org_network" "vapp-net-webdmz" {
  vapp_name        = vcd_vapp.my-vapp.name
  org_network_name = vcd_network_routed_v2.my-webdmz.name
}

// Deploy webserver VM
resource "vcd_vapp_vm" "my-webserver" {
  vapp_name     = vcd_vapp.my-vapp.name
  name          = "TF-webserver"
  catalog_name  = vcd_catalog.my-catalog.name
  template_name = vcd_catalog_item.photon-os-ova.name
  memory        = 1024
  cpus          = 1

  network {
    type               = "org"
    name               = vcd_vapp_org_network.vapp-net-webdmz.org_network_name
    ip_allocation_mode = "POOL"
    is_primary         = true
  }

  customization {
    enabled                             = true
    auto_generate_password              = true
    must_change_password_on_first_login = true
    initscript                          = file("setup.sh")
  }

  power_on = true
}

// Create destination NAT rule
resource "vcd_nsxv_dnat" "webdmz-dnat" {
  description        = "WebDMZ DNAT (Terraform managed, do not delete)"
  edge_gateway       = var.vcd_edgegateway
  network_type       = "ext"
  network_name       = one(data.vcd_edgegateway.my-edge-gw.external_network[*].name)
  original_address   = data.vcd_edgegateway.my-edge-gw.external_network_ips[0]
  translated_address = vcd_vapp_vm.my-webserver.network[0].ip
  original_port      = 80
  protocol           = "tcp"
  translated_port    = 80
  depends_on         = [vcd_vapp_vm.my-webserver]
}

// Output information
output "public_IP_address" {
  value = join("", ["Visit for result: http://", data.vcd_edgegateway.my-edge-gw.default_external_network_ip, "\nThis is available shortly, after install of a webserver."])
}
output "root_password" {
  value     = vcd_vapp_vm.my-webserver.customization[0].admin_password
  sensitive = true
}

output "remark" {
  value = "Run the following command to reveal the initial root password: terraform output root_password"
}
