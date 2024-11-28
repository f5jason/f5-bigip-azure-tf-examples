# Deploys base network infrastructure and a single 3-NIC BIG-IP

## Note: Alien subnet (10.10.10.0/24) used for F5 Virtual Servers

Tasks:
   - Create Resource Group
   - Create Virtual Network with Subnets
      - management
      - external
      - internal
      - application
   - Deploy a single BIG-IP VE - bigip1
   - Deploy linux jumphost in 'management' and 'external' subnet
   - Deploy demo application server in 'application' subnet
   - Create NSG allowing access from remote host IP and associate to 'management' and 'external' subnets
   - Create Route Table with route to alien subnet via future Azure LB frontend IP

Outputs (example):
   - admin_password = "rPfhy4tz6Z7iJmlW"
   - bigip1_management_pip = "ssh azureuser@52.237.19.104 pass: rPfhy4tz6Z7iJmlW"
   - demo_vnet = "my_demo_vnet"
   - jumphost_management_pip = "ssh azureuser@52.237.24.227 pass: rPfhy4tz6Z7iJmlW"
   - remote_client_ip = "100.241.246.116"
   - resource_group = "my_rg"