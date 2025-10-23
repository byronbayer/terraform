module "azure_location" {
  source   = "azurerm/locations/azure"
  location = var.location
}