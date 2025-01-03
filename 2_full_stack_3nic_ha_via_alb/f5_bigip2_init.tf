# Build BIG-IP DO and Runtime-init configs from templates. This is used as the VM custom_data.
# Local copies of these configs are saved only for reference purposes.
#
# Note: AS3 config is built and deployed with BIG-IP #1 only, then automatically synchronized to this BIG-IP.
#

#
# Declarative Onboarding
#

# Generate DO declaration from template
data "template_file" "f5-do-bigip2-json" {
  template = file("${path.module}/templates/f5-do-3nic-ha-payg.json.tmpl") ### For PAYG licensing only
  # template = file("${path.module}/templates/f5-do-3nic-ha-byol.json.tmpl") ### For BYOL licensing only

  vars = {

    # For BYOL licenses, use the BYOL DO template (above) and uncomment the next line
    # license_key       = var.byol_licenses["bigip2"]

    # BIG-IP #2 HA Config
    cluster_member0_ip = split("/", var.bigip_netcfg["bigip1"]["management"])[0]
    cluster_member1_ip = split("/", var.bigip_netcfg["bigip2"]["management"])[0]

    # Common Config
    admin_username  = var.admin_username
    admin_password  = local.admin_password
    hostname        = var.bigip_netcfg["bigip2"]["hostname"]
    external_selfip = var.bigip_netcfg["bigip2"]["external"]
    internal_selfip = var.bigip_netcfg["bigip2"]["internal"]
    default_gw      = var.bigip_netcfg["bigip2"]["default_gw"]
    dns_servers     = var.dns_servers
    ntp_servers     = var.ntp_servers
    timezone        = var.timezone
    app_route_dest  = var.app_route["dest"]
    app_route_gw    = var.app_route["gateway"]
  }
}

# Save local copy of DO declaration files
resource "local_file" "f5-do-bigip2-json" {
  content  = data.template_file.f5-do-bigip2-json.rendered
  filename = "${path.module}/outputs/f5-init-do-bigip2.json"
}


#
# AS3
#

## Generate AS3 declaration for Azure LB health probes - only for the first BIG-IP deployment. Comment this out for subsequent deployments.
#data "template_file" "f5-as3-alb-probe-json" {
#  template = file("${path.module}/templates/f5-as3-alb-probe.json.tmpl")
#}
#
## Create local copy of AS3 declaration file
#resource "local_file" "f5-as3-alb-probe-json" {
#  content  = data.template_file.f5-as3-alb-probe-json.rendered
#  filename = "${path.module}/outputs/f5-init-as3-alb-probe.json"
#}


## Generate AS3 declaration for demo app - only for the first BIG-IP deployment. Comment this out for subsequent deployments.
#data "template_file" "f5-as3-app1-json" {
#  template = file("${path.module}/templates/f5-as3-app1.json.tmpl")
#  vars = {
#    app_dest       = "${var.app1_vs["dest"]}/32"
#    app_port       = tonumber(var.app1_vs["port"])
#    app_pool       = "${var.app1_vs["pool"]}"
#    app_poolmember = "${var.app1_vs["poolmember"]}"
#    app_monitor    = "${var.app1_vs["monitor"]}"
#  }
#}
#
## Create local copy of AS3 declaration file
#resource "local_file" "f5-as3-app1-json" {
#  content  = data.template_file.f5-as3-app1-json.rendered
#  filename = "${path.module}/outputs/f5-init-as3-app1.json"
#}


#
# Runtime-init
#

# Generate runtime-init config from template
data "template_file" "f5-init-bigip2-json" {
  template = file("${path.module}/templates/f5-runtime-init-bigip2.json.tmpl")
  vars = {
    f5-do-json            = indent(10, "${data.template_file.f5-do-bigip2-json.rendered}")
    f5-as3-alb-probe-json = indent(10, "${data.template_file.f5-as3-alb-probe-json.rendered}")
    f5-as3-app1-json      = indent(10, "${data.template_file.f5-as3-app1-json.rendered}")
  }
}

# Generate startup script to install and execute runtime-init
data "template_file" "f5-init-startup-bigip2" {
  template = file("${path.module}/templates/f5-startup.sh.tmpl")
  vars = {
    f5-runtime-init = "${data.template_file.f5-init-bigip2-json.rendered}"
  }
}

# Save local copy of startup script
resource "local_file" "f5-startup-script-bigip2" {
  content  = data.template_file.f5-init-startup-bigip2.rendered
  filename = "${path.module}/outputs/f5-init-startup-bigip2.sh"
}
