terraform {
  backend "azurerm" {
    key = "prod/terraform.tfstate"
  }
}