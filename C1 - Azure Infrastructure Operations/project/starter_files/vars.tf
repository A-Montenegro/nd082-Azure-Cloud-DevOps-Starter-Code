variable "prefix" {
  default = "alberto_martinez"
}

variable "number_of_vms" {
  default = 2
}

variable "packer_resource_group_name" {
   description = "rg of packer image"
   default     = "packer"
}

variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "myPackerImage"
}
