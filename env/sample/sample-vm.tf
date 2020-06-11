################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : 仮想マシン作成用の変数を渡す
## @since   : 2020/06/09
## @see     :
################################################################################

locals {
  ##### mapのキー #####
  # ehable_boot_diagnostics : ブート診断の有無
  # ehable_backup           : バックアップ有無
  # resource_group_key、subnet_keyは必須。その他の割当不要なリソースのkeyは""（空文字）とする。
  main-vm_var = {
    resource_group_key            = "rg1"
    subnet_key                    = "sub1"
    ehable_boot_diagnostics       = false
    ehable_backup                 = false
    storage_account_key           = "sa1"
    availability_set_key          = ""
    proximity_placement_group_key = ""
    public_ip_key                 = ""
    recovery_services_vault_key   = ""
    backup_policy_vm_key          = ""
  }
}

locals {
  ##### 仮想マシン #####
  sample-vm_vm = {

    name                         = "sample-vm"
    resource_group_name          = module.main.resource_group[local.sample-vm_var.resource_group_key].name
    location                     = module.main.resource_group[local.sample-vm_var.resource_group_key].location
    vm_size                      = "Standard_D2s_v3"
    availability_set_id          = length(local.sample-vm_var.availability_set_key) > 0 ? module.main.availability_set[local.sample-vm_var.availability_set_key].id : ""
    proximity_placement_group_id = length(local.sample-vm_var.proximity_placement_group_key) > 0 ? module.main.proximity_placement_group[local.sample-vm_var.proximity_placement_group_key].id : ""

    ##### ディスク関連 #####
    delete_os_disk_on_termination    = false
    delete_data_disks_on_termination = false
    ultra_ssd_enabled                = false

    ##### 仮想マシンイメージ #####
    # is_windows_image  : Windowsイメージの使用有無
    # os_id             : カスタムイメージを使用する場合、IDを入力
    # publisher         : 例：MicrosoftWindowsServer, RedHat, Canonical, OpenLogic
    # offer             : 例：WindowsServer, RHEL, UbuntuServer, CentOS
    # sku               : 例：2019-Datacenter, 7.8, 18.04-LTS, 7.8
    # version           : 最新はlatest
    image = {
      is_windows_image = true
      os_id            = ""
      publisher        = "MicrosoftWindowsServer"
      offer            = "WindowsServer"
      sku              = "2019-Datacenter"
      version          = "latest"
    }

    ##### OSディスク #####
    # managed_disk_type : Standard_LRS, StandardSSD_LRS, Premium_LRS
    os_disk = {
      managed_disk_type         = "Standard_LRS"
      write_accelerator_enabled = false
    }

    ##### 仮想ネットワーク #####
    network = {
      subnet_id                     = module.main.subnet[local.sample-vm_var.subnet_key].id
      private_ip_address            = "10.0.0.5"
      public_ip_address_id          = length(local.sample-vm_var.public_ip_key) > 0 ? module.main.public_ip[local.sample-vm_var.public_ip_key].id : ""
      enable_accelerated_networking = false
    }

    ##### ローカル管理者 #####
    os_profile = {
      admin_username = "sampleadmin"
      admin_password = ""
    }

    ##### ブート診断 #####
    boot_diagnostics = {
      ehable_boot_diagnostics = local.sample-vm_var.ehable_boot_diagnostics
      primary_blob_endpoint   = local.sample-vm_var.ehable_boot_diagnostics ? module.main.storage_account[local.sample-vm_var.storage_account_key].primary_blob_endpoint : ""
    }

    ##### Windows個別設定 #####
    windows = {
      timezone = "Tokyo Standard Time"
    }

    ##### Linux個別設定 #####
    linux = {
      enable_ssh_key = false
      ssh_key        = ""
    }

    ##### Backup #####
    # バックアップ取得頻度に合わせてコメントアウトする
    # backup_policy_vm_daily  :日次
    # backup_policy_vm_weekly :週次
    backup = {
      recovery_vault_name = local.sample-vm_var.ehable_backup ? module.main.recovery_services_vault[local.sample-vm_var.recovery_services_vault_key].name : ""
      backup_policy_id    = local.sample-vm_var.ehable_backup ? module.main.backup_policy_vm_daily[local.sample-vm_var.backup_policy_vm_key].id : ""
      # backup_policy_id = local.sample-vm_var.ehable_backup ? module.main.backup_policy_vm_weekly[local.sample-vm_var.backup_policy_vm_key].id : ""
    }

    ##### Load Balancer #####
    load_balancer = {
      ehabled_load_balancer   = true
      backend_address_pool_id = module.main-lb.lb_backend_address_pool.id
    }

    tags = {
      name = "サンプル仮想マシン"
    }
  }

  ##### データディスク #####
  # アタッチするディスクの数だけmapを増やす
  # managed_disk_type : Standard_LRS, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
  # caching           : None, ReadOnly, ReadWrite
  sample-vm_data_disk = {
    "disk1" = {
      disk_size_gb              = "16"
      managed_disk_type         = "Standard_LRS"
      caching                   = "ReadOnly"
      lun                       = 0
      write_accelerator_enabled = false
    }
  }

}

##### 仮想マシンの作成 #####
module "sample-vm" {
  source = "../../modules/vm/"

  vm        = local.sample-vm_vm
  data_disk = local.sample-vm_data_disk
}
