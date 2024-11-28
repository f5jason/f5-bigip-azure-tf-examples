# Base network infrastructure to support a 3-NIC BIG-IP HA via LB deployment

## Note: Alien subnet (10.10.10.0/24) used for F5 Virtual Servers

Tasks:
   - Create Resource Group
   - Create Virtual Network with Subnets
      - management
      - external
      - internal
      - application
   - Deploy linux jumphost in 'management' and 'external' subnet
   - Deploy demo application server in 'application' subnet
   - Create NSG for management access from remote host IP
   - Associate NSG to 'management' and 'external' subnets
   - Create Azure Load Balancer with LB rule forwarding to 2 BIG-IP VE external interfaces
   - Create Route Table with route to alien subnet via Azure LB frontend IP

Outputs (example):
   - admin_password = "vNEjo7sU7Z9iBCgy"
   - demo_vnet = "my_demo_vnet"
   - jumphost_management_pip = "ssh azureuser@4.204.69.78 pass: vNEjo7sU7Z9iBCgy"
   - remote_client_ip = "100.219.105.84"
   - resource_group = "my_rg"