# F5 BIG-IP deployment in Azure with Terraform

This repository contains some Terraform examples to deploy BIG-IP VE instances in Azure.

**WARNING:** These examples are provided without warranty and are not supported by F5.

**Examples**

1. Full stack deployment with a single BIG-IP.
2. Full stack deployment with 2 BIG-IPs configured for HA failover via an Azure internal load balancer.

**Notes**

- You can choose between PAYG and BYOL licensing options (some editing required).

- The following extensions are leverage to automate the onboarding and initial application configuration:

  1. BIG-IP Runtime-Init
  2. Declarative Onboard (DO)
  3. Application Services 3 (AS3)


