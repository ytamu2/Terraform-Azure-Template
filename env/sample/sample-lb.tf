################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : Load Balancer作成用の変数を渡す
## @since   : 2020/06/09
## @see     :
################################################################################
locals {
  ##### mapのキー #####
  sample-lb_var = {
    resource_group_key = "rg1"
    subnet_key         = "sub1"
  }
}

locals {
  ##### Load Balancer #####
  # sku         : Basic, Standard
  # is_private  : 内部Loac Balancerの場合はtrue
  sample-lb_lb = {
    name                = "sample-lb"
    resource_group_name = module.main.resource_group[local.sample-lb_var.resource_group_key].name
    location            = module.main.resource_group[local.sample-lb_var.resource_group_key].location
    sku                 = "Basic"
    is_private          = true

    ##### フロントエンドIP #####
    # private_ip_address_allocation : Dynamic, Static （パブリックの場合はDynamicに設定する）
    # private_ip_address_version    : IPv4, IPv6
    frontend_ip_configuration = {
      name                          = "frontend01"
      subnet_id                     = module.main.subnet[local.sample-lb_var.subnet_key].id
      private_ip_address            = "10.0.0.10"
      private_ip_address_allocation = "Static"
      private_ip_address_version    = "IPv4"
      public_ip_address_id          = ""
    }

    ##### バックエンドプール #####
    backend_address_pool_name = "backendpool01"

    ##### 正常性プローブ #####
    # protocol            : Http, Https, Tcp
    # interval_in_seconds : 5-2147483646
    # number_of_probes    : 2-429496729
    probe = {
      "prb1" = {
        name                = "plobe01"
        protocol            = "Tcp"
        port                = 443
        interval_in_seconds = 15
        number_of_probes    = 2
      }
    }

    tags = {
      name = "サンプルロードバランサー"
    }

  }

  ##### 負荷分散規則 #####
  # protocol                : Tcp, Udp, All
  # idle_timeout_in_minutes : 4-30/分
  sample-lb_lb_rule = {
    "rule1" = {
      name                    = "lb_rule01"
      resource_group_name     = local.sample-lb_lb.resource_group_name
      protocol                = "Tcp"
      frontend_port           = "443"
      backend_port            = "443"
      enable_floating_ip      = false
      idle_timeout_in_minutes = 4
      disable_outbound_snat   = false
      enable_tcp_reset        = false
      plobe_key               = "prb1"
      description             = "https"
    },
    "rule2" = {
      name                    = "lb_rule02"
      resource_group_name     = local.sample-lb_lb.resource_group_name
      protocol                = "Tcp"
      frontend_port           = "445"
      backend_port            = "445"
      enable_floating_ip      = true
      idle_timeout_in_minutes = 10
      disable_outbound_snat   = false
      enable_tcp_reset        = false
      plobe_key               = "prb1"
      description             = "SMB"
    }
  }
}

##### Load Balancerの作成 #####
module "sample-lb" {
  source = "../../modules/lb/"

  lb      = local.sample-lb_lb
  lb_rule = local.sample-lb_lb_rule
}
