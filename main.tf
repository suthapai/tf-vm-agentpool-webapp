resource "azurerm_resource_group" "rg-grp" {
  name     = var.resource_group_name
  location =  var.location
}

resource "azurerm_virtual_network" "agent-vnet" {
  name                = var.agent-vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-grp.location
  resource_group_name = azurerm_resource_group.rg-grp.name
}

resource "azurerm_subnet" "agent-subnet" {
  name                 = var.agent-subnet
  resource_group_name  = azurerm_resource_group.rg-grp.name
  virtual_network_name = azurerm_virtual_network.agent-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.agentip
  resource_group_name = azurerm_resource_group.rg-grp.name
  location            = var.location
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "nic-cd" {
  name                = var.agent-nic
  location            = azurerm_resource_group.rg-grp.location
  resource_group_name = azurerm_resource_group.rg-grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.agent-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = var.nssg
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-grp.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_publicIP"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic-cd.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.agent_vm_name
  resource_group_name = azurerm_resource_group.rg-grp.name
  location            = azurerm_resource_group.rg-grp.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.nic-cd.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-server"
    sku       = "24_04-lts"
    version   = "latest"
  }
}
//retrive data from vm created for public-ip
data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = azurerm_resource_group.rg-grp.name
  depends_on          = [azurerm_linux_virtual_machine.main]
}

output "ip_address" {
  value = data.azurerm_public_ip.public_ip.ip_address
}
## Install Docker and Configure Self-Hosted Agent
resource "null_resource" "install_docker" {
  provisioner "remote-exec" {
    inline = ["${file("\\script.sh")}"]
    #inline = ["${file("D:\\Nagarro\\Pramotions\\InfrastructureCode\\VM\\script.sh")}"]
    connection {
      type     = "ssh"
      user     = azurerm_linux_virtual_machine.main.admin_username
      password = azurerm_linux_virtual_machine.main.admin_password
      host     = data.azurerm_public_ip.public_ip.ip_address
      timeout  = "10m"
    }
  }
}
