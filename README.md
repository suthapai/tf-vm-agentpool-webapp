#Terraform Practical

Creating Azure DevOps Self-Hosted Agent on Azure Virtual Machine + Software Installation- through terraform configuration scripts.

 Requirements:

provider.tf- configuration file with provider info and service-principal details.

main.tf- resources-resourcegrp, vnet, subnet, securitygrp, vm, nic also connect vm and execute script.sh file

script.sh- file with installation script for docker,kubectl,agent pool

variables.tf-required variables used

terraform.tfvars-file with variable values
