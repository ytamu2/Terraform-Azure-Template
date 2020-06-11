################################################################################
## Copyright(c) 2020 BeeX Inc. All rights reserved.
## @author  : Yasutoshi Tamura
## @summary : env配下で設定した値を受け取る変数
## @since   : 2020/06/10
## @see     :
################################################################################
variable "resource_group" {}

variable "virtual_network" {}

variable "subnet" {}

variable "public_ip" {}

variable "availability_set" {}

variable "storage_account" {}

variable "recovery_services_vault" {}

variable "backup_policy_vm_daily" {}

variable "backup_policy_vm_weekly" {}

variable "proximity_placement_group" {}

variable "backup_storage_account" {}
