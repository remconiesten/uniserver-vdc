locals {
  fwrules = {
    "webdmz-outbound-allow" = {
      description = "Outbound WebDMZ allow (TF managed)"
      src_cidr    = [var.webdmz_cidr]
      dst_cidr    = ["any"]
      dst_port    = "any"
      protocol    = "any"
    }
    "webdmz-inbound-allow" = {
      description = "Inbound WebDMZ allow (TF managed)"
      src_cidr    = ["any"]
      dst_cidr    = ["${data.vcd_edgegateway.my-edge-gw.default_external_network_ip}"]
      dst_port    = "80"
      protocol    = "tcp"
    }
    "icmp-allow" = {
      description = "IMCP for diag allow (TF managed)"
      src_cidr    = ["any"]
      dst_cidr    = ["any"]
      dst_port    = "any"
      protocol    = "icmp"
    }
  }
}