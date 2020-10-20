output "ip_address" {
  value = azurerm_container_group.app.ip_address
}

#the dns fqdn of the container group if dns_name_label is set
output "fqdn" {
  value = "http://${azurerm_container_group.app.fqdn}:8080"
}

output "contrast" {
  value = "This app should appear in the environment ${data.external.yaml.result.url}"
}

