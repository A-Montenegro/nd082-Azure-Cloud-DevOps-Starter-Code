# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
The target of this project is to create a Terraform template to deploy a customizable, scalable web server in Azure.
The porject includes a packer template that generates an image that will be used by terraform to create the virtual machines.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Use the packer template and the terraform files as described in the instruction below.


### Instructions
1. Gnerate the VM image using the packer template using the command `packer build server.json`.
2. Edit the vars.tf file to customize the deployment. You can customize the following variables:
   - prefix: The prefix which be added to names of your Azure resources.
   - number_of_vms: The number of vms that will be created.
   - packer_resource_group_name: The resource group where the packer image is located.
   - packer_image_name: Name of the packer image.
3. Execute the command `terraform plan -out solution.plan`
4. Execute the command `terraform apply`

### Output
The output file `solution.plan` will be generated after the step 3 of the instructions.
You can find all the information about the deploymen in this file.
