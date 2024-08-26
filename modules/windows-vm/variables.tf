////////////////////////
// SQL-VM | Variables
////////////////////////

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
}

variable "subnet" {
  type = object({
    id                   = string
    name                 = string
    virtual_network_name = string
    resource_group_name  = string
  })
}

variable "tags" {}   // Pass any parameters
variable "params" {} // Pass any parameters