# 概要

Azure 用 Terraform 定義のテンプレートです。

# ディレクトリ構成

```
│  availability.tf
│  recovery_services_vault.tf
│  resource_group.tf
│  storage_account.tf
│  variables.tf
│  virtual_network.tf
│
├─env
│  ├─sample
│  │       main.tf
│  │       sample-lb.tf
│  │       sample-nsg.tf
│  │       sample-vm.tf
│  │       variables.tf
│  │
└─modules
    ├─lb
    │      lb.tf
    │      outputs.tf
    │      variables.tf
    │
    ├─nsg
    │      nsg.tf
    │      variables.tf
    │
    └─vm
            outputs.tf
            variables.tf
            vm.tf
```

# 対応リソース

-   Resource Group
-   Virtual Network
-   Subnet
-   Network Security Group
-   Virtual Machines
-   Public IP Address
-   Load Balancer
-   Availability Set
-   Proximity Placement Group
-   Storage Account
-   Recovery Services Vault

# 使用方法

## 定義

リソースは env\<環境>\variables.tf の変数の map 部分をコメントアウト、または削除することで作成有無を制御できます。  
リソース作成の tf ファイル存在時に変数ごとコメントアウトすると、エラーとなりますのでご注意ください。

```
 public_ip = {
    # pip1 = {
    #   name               = "vm1-pip"
    #   resource_group_key = "rg1"
    #   sku                = "Basic"
    #   allocation_method  = "Static"
    # }
  }
```

リソースを複数作成する場合は、map を追加してください。

```
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
```

modules にあるリソースを複数作成する場合は、`sample-xx.tf`をコピーして複数ファイル用意してください。

## 実行

認証は事前に`Azure CLI`でログインするか`サービスプリンシパル`の認証処理を追加してください。  
env\<環境>ディレクトリから実行してください。
