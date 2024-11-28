# Determine the public IP address of the remote client machine and use it in the security
# group ACLs to restrict access to the lab resources.

data "http" "myip" {
  url = "https://ifconfig.me/ip"
}

locals {
  remote_client_ip = [format("%s/32", data.http.myip.response_body)]
}

output "remote_client_ip" {
  value = data.http.myip.response_body
}

