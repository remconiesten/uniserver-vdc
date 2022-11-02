// Declare access to Organization Virtual Datacenter
//vcd_auth_type = "integrated"
vcd_auth_type = "api_token"

// Integrated authentication (username & password)
//vcd_user     = ""
//vcd_password = ""

// Token authentication
vcd_user      = "none"
vcd_password  = "none"
vcd_api_token = "*****" // Put your access token in here

// Org VDC specification
org_name = "ORG-C*****" // This is the Virtual Datacenter ORG
org_vdc  = "VDC-C*****-**-*****" // This is the OrgVDC to use for deployed resources
//vcd_url                  = "https://ucp.uniserver.nl/api"

// Edge gateway to use
// Find out the correct one in the vCloud Director GUI
vcd_edgegateway = "edge-C*****-***" // Find out the Edge Gateway name in the Virtual Datacenter portal, under 'networking' -> 'edges'

// Internal network range to use
webdmz_cidr               = "172.17.17.0/24"
webdmz_gateway            = "172.17.17.254"
webdmz_staticippool_start = "172.17.17.11"
webdmz_staticippool_end   = "172.17.17.100"

// DNS
dns1 = "195.69.75.11"
dns2 = "83.143.187.137"

// OVA to use
// Make sure this is downloaded on your local system!
// Photon OS can be found at https://github.com/vmware/photon/wiki/Downloading-Photon-OS
// Make sure to pick the hardware v11 variant for maximum compatibility!
ova_image = "./ova/*****.ova" // Reference a valid OVA file here