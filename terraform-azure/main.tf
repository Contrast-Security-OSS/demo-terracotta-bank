#Terraform `provider` section is required since the `azurerm` provider update to 2.0+
provider "azurerm" {
  features {
  }
}

#Extract the connection from the normal yaml file to pass to the app container
data "external" "yaml" {
  program = [var.python_binary, "${path.module}/parseyaml.py"]
}

#Set up a personal resource group for the SE local to them
resource "azurerm_resource_group" "personal" {
  name     = "Sales-Engineer-${var.initials}"
  location = var.location
}

#Set up a container group 
resource "azurerm_container_group" "app" {
  name                = "${var.appname}-${var.initials}"
  location            = azurerm_resource_group.personal.location
  resource_group_name = azurerm_resource_group.personal.name
  ip_address_type     = "Public"
  dns_name_label      = "${replace(var.appname, "/[^-0-9a-zA-Z]/", "-")}-${var.initials}"
  os_type             = "Linux"

  container {
    name   = "web"
    image  = "contrastsecuritydemo/terracotta-bank:1.0"
    cpu    = "1"
    memory = "1.5"
    ports {
      port     = 8080
      protocol = "TCP"
    }
    environment_variables = {
      JAVA_TOOL_OPTIONS = "-javaagent:/opt/contrast/contrast.jar -Dcontrast.api.url=${data.external.yaml.result.url} -Dcontrast.api.api_key=${data.external.yaml.result.api_key} -Dcontrast.api.service_key=${data.external.yaml.result.service_key} -Dcontrast.api.user_name=${data.external.yaml.result.user_name} -Dcontrast.application.name=${var.appname} -Dcontrast.server.name=${var.servername} -Dcontrast.server.environment=${var.environment} -Dcontrast.application.session_metadata=${var.session_metadata} -Dcontrast.application.tags=${var.apptags} -Dcontrast.server.tags=${var.servertags}"
    }
  }
}