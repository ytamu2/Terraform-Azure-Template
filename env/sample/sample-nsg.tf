################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : Network Security Group作成用の変数を渡す
## @since   : 2020/06/09
## @see     :
################################################################################
locals {
  ##### mapのキー #####
  sample-nsg_var = {
    resource_group_key = "rg1"
  }
}

locals {
  ##### NSG #####
  # is_attach_subnet  : サブネットへのNSGアタッチ有無
  sample-nsg_nsg = {
    name                 = "sample-nsg"
    resource_group_name  = module.main.resource_group[local.sample-nsg_var.resource_group_key].name
    location             = module.main.resource_group[local.sample-nsg_var.resource_group_key].location
    is_attach_subnet     = true
    network_interface_id = ""
    subnet_association = {
      1 = {
        id = module.main.subnet["sub1"].id
      }
    }
    nic_association = {
      # 1 = {
      #   id = module.main-vm.network_interface.id
      # }
    }

    tags = {
      name = "サンプルNSG"
    }
  }

  ##### セキュリティルール #####
  # priority                      : 100-4096
  # direction                     : Inbound, Outbound
  # access                        : Allow, Deny
  # protocol                      : TCP, UDP, ICMP
  # source_address_prefix         : *, CIDR, <Service Tag>
  # destination_address_prefixes  : CIDR
  sample-nsg_security_rule = {
    "rule1" = {
      name                         = "${local.security_rule_Prefix.deny}_rule01"
      resource_group_name          = local.sample-nsg_nsg.resource_group_name
      location                     = local.sample-nsg_nsg.location
      network_security_group_name  = local.sample-nsg_nsg.name
      priority                     = 100
      direction                    = "Inbound"
      access                       = local.security_rule_Prefix.deny
      protocol                     = "TCP"
      source_address_prefix        = "Internet"
      source_port_range            = "*"
      destination_address_prefixes = ["10.0.0.0/16"]
      destination_port_ranges      = ["443", "80"]
      description                  = "インターネットアクセス拒否"
    },
    "rule2" = {
      name                         = "${local.security_rule_Prefix.deny}_rule02"
      resource_group_name          = local.sample-nsg_nsg.resource_group_name
      location                     = local.sample-nsg_nsg.location
      network_security_group_name  = local.sample-nsg_nsg.name
      priority                     = 200
      direction                    = "Inbound"
      access                       = local.security_rule_Prefix.deny
      protocol                     = "TCP"
      source_address_prefix        = "*"
      source_port_range            = "*"
      destination_address_prefixes = ["10.0.0.0/24", "10.0.1.0/24"]
      destination_port_ranges      = ["3389"]
      description                  = "RDP拒否"
    }
  }
}

##### NSGの作成とアタッチ #####
module "sample-nsg" {
  source = "../../modules/nsg/"

  nsg           = local.sample-nsg_nsg
  security_rule = local.sample-nsg_security_rule
}
