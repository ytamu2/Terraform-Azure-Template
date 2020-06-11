################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : 変数の宣言
## @since   : 2020/06/10
## @see     :
################################################################################
locals {
  ##### Azureログイン情報 #####
  login = {
    subscription_id = ""
    tenant_id       = ""
  }

  location = {
    main = "japaneast"
    sub  = "japanwest"
  }

  ##### リソースグループ #####
  resource_group = {
    rg1 = {
      name     = "sample-rg"
      location = local.location.main
    }
  }

  ##### 仮想ネットワーク #####
  virtual_network = {
    vnet1 = {
      name               = "sample-vnet"
      resource_group_key = "rg1"
      address_space      = ["10.0.0.0/23"]
    }
  }

  ##### サブネット #####
  # service_endpoints : Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, 
  #                   : Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Web.
  subnet = {
    sub1 = {
      name                = "vm1-sub"
      address_prefixes    = ["10.0.0.0/25"]
      resource_group_key  = "rg1"
      virtual_network_key = "vnet1"
      service_endpoints   = ["Microsoft.Storage"]
    },
    sub2 = {
      name                = "vm2-sub"
      address_prefixes    = ["10.0.0.128/25"]
      resource_group_key  = "rg1"
      virtual_network_key = "vnet1"
      service_endpoints   = ["Microsoft.Storage"]
    }
  }

  ##### パブリックIP #####
  # sku               : Basic, Standard
  # allocation_method : Static, Dynamic
  public_ip = {
    # pip1 = {
    #   name               = "vm1-pip"
    #   resource_group_key = "rg1"
    #   sku                = "Basic"
    #   allocation_method  = "Static"
    # }
  }

  ##### 可用性セット #####
  availability_set = {
    # avset1 = {
    #   name                          = "sample-avset"
    #   resource_group_key            = "rg1"
    #   platform_fault_domain_count   = 2
    #   platform_update_domain_count  = 5
    #   proximity_placement_group_key = "ppg1"
    # }
  }

  ##### 近接通信配置グループ #####
  proximity_placement_group = {
    # ppg1 = {
    #   name               = "sample-ppg"
    #   resource_group_key = "rg1"
    # }
  }

  ##### ストレージアカウント #####
  # account_kind              : Storage, StorageV2, BlobStorage, BlockBlobStorage, FileStorage
  # account_tier              : Standard, Premium
  # account_replication_type  : LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS
  # access_tier               : Hot, Cool
  # default_action            : Allow, Deny
  # bypass                    : Logging, Metrics, AzureServices, None
  storage_account = {
    # sa1 = {
    #   name                     = "samplesa"
    #   resource_group_key       = "rg1"
    #   account_kind             = "StorageV2"
    #   account_tier             = "Standard"
    #   account_replication_type = "LRS"
    #   access_tier              = "Hot"
    #   recovery_vault_key       = "rsc1"
    #   default_action           = "Allow"
    #   bypass                   = []
    #   ip_rules                 = []
    #   allow_subnets            = []
    # }
  }

  ##### ストレージアカウントのバックアップ #####
  # keyはストレージアカウントと同じにする
  backup_storage_account = {
    # sa1 = {
    #   resource_group_key = "rg1"
    #   recovery_vault_key = "rsc1"
    # }
  }

  security_rule_Prefix = {
    allow = "Allow"
    deny  = "Deny"
  }

  ##### Recovery Servicesコンテナー #####
  # sku : Standard, RS0
  recovery_services_vault = {
    rsc1 = {
      name                = "sample-rsc01"
      resource_group_key  = "rg1"
      sku                 = "Standard"
      soft_delete_enabled = true
      # storage_account_key = "sa1"
    }
  }

  ##### 日次バックアップポリシー #####
  # count : 7 - 9999
  backup_policy_vm_daily = {
    pold1 = {
      name               = "sample-pol-daily01"
      resource_group_key = "rg1"
      timezone           = "Tokyo Standard Time"
      time               = "01:00"
      count              = 7
      recovery_vault_key = "rsc1"
    }
  }

  ##### 週次バックアップポリシー #####
  # count     : 1 - 9999
  # weekdays  : Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
  backup_policy_vm_weekly = {
    # polw1 = {
    #   name               = "sample-pol-weekly01"
    #   resource_group_key = "rg1"
    #   timezone           = "Tokyo Standard Time"
    #   time               = "02:00"
    #   count              = 1
    #   weekdays           = ["Sunday"]
    #   recovery_vault_key = "rsc1"
    # }
  }

}
