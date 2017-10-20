variable "resource_group_name" {}
variable "prefix" {}
variable "location" {}
variable "storage_account_name" {}
variable "storage_account_type" {default = "Standard_GRS"}
variable "storage_account_kind" {default = "Storage"}
variable "storage_account_tier" {default     = "Standard"}
variable "storage_account_replication_type" {default     = "LRS"}
variable "enabled_ip_forwarding" {default = false}
variable "subnet_id" {}
variable "vm_computer_name" {}
variable "vm_name_prefix" {}
variable "vm_admin_password" {}
variable "vm_admin_username" {}
variable "vm_size" { default = "Standard_DS1_v2" }
variable "vm_image_uri" {}


resource "azurerm_public_ip" "transferpip" {
  name                         = "transferpip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "transfernic" {
  name                = "transfernic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${azurerm_public_ip.transferpip.name}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "Static"
    public_ip_address_id          = "${azurerm_public_ip.transferpip.id}"
    private_ip_address            = "10.0.1.5"
  }
}

resource "azurerm_virtual_machine" "transfer" {
  name                  = "mytransfervm"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.transfernic.id}"]

  storage_os_disk {
    name          = "${var.vm_name_prefix}-osdisk"
    image_uri     = "${var.vm_image_uri}"
    vhd_uri       = "https://tspackerimagessandbox.blob.core.windows.net/tspackerimagessandbox-vhds/${var.vm_name_prefix}-osdisk.vhd"
    os_type       = "windows"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "mytransfervm"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }
}
