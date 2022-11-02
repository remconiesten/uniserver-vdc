terraform {
  required_providers {
    // This provider has documentation at:
    // https://registry.terraform.io/providers/vmware/vcd/latest/docs
    vcd = {
      source = "vmware/vcd"
    }
  }
}

// Declare connection to vCloud Director
provider "vcd" {
  url              = var.vcd_url
  user             = var.vcd_user
  password         = var.vcd_password
  org              = var.org_name
  vdc              = var.org_vdc
  auth_type        = var.vcd_auth_type
  api_token        = var.vcd_api_token

  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}