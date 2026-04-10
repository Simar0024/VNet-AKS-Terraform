# Bastion Module - Main Configuration

# ============================================================================
# PUBLIC IP FOR BASTION
# ============================================================================

resource "azurerm_public_ip" "bastion" {
  count               = var.create_bastion_vm ? 1 : 0
  name                = "pip-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"

  tags = var.tags
}

# ============================================================================
# AZURE BASTION SERVICE
# ============================================================================

resource "azurerm_bastion_host" "main" {
  count               = var.create_bastion_vm ? 1 : 0
  name                = "bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                = "Standard"
  ip_connect_enabled  = true
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = var.bastion_service_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  tags = var.tags

  depends_on = [
    azurerm_public_ip.bastion
  ]
}

# ============================================================================
# NSG FOR BASTION SUBNET
# ============================================================================

resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowBastionToVNet"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# ============================================================================
# BASTION VM NETWORK INTERFACE
# ============================================================================

resource "azurerm_network_interface" "bastion_vm" {
  count               = var.create_bastion_vm ? 1 : 0
  name                = "nic-bastion-vm-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = var.management_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}
# ============================================================================
# BASTION JUMP/ADMIN VM
# ============================================================================

resource "azurerm_linux_virtual_machine" "bastion_vm" {
  count = var.create_bastion_vm ? 1 : 0

  name                = var.bastion_vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_D2s_v3"

  admin_username                  = var.bastion_admin_user
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.bastion_vm[0].id,
  ]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = var.disk_encryption_set_id
  }

  source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}

  identity {
    type         = "UserAssigned"
    identity_ids = [var.bastion_managed_identity_resource_id]
  }

  admin_ssh_key {
    username   = var.bastion_admin_user
    public_key = var.bastion_admin_ssh_key
  }

  tags = var.tags
}

# Note: Disk encryption is configured at the resource level (os_disk block)
# in the azurerm_linux_virtual_machine resource above

# ============================================================================
# DIAGNOSTIC SETTINGS FOR BASTION
# ============================================================================

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  count                      = var.enable_diagnostics && var.create_bastion_vm ? 1 : 0
  name                       = "diag-bastion-${var.environment}"
  target_resource_id         = azurerm_bastion_host.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
