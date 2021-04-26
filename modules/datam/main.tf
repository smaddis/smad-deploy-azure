# https://www.ahead.com/resources/how-to-leverage-hashicorp-terraform-remote-state/
# https://www.terraform.io/docs/language/state/remote-state-data.html

data "terraform_remote_state" "storagestate" {
  backend = "azurerm"
  config = {
    resource_group_name  = "kuksatrng-tfstate-rg"
    storage_account_name = "kuksatrngtfstatesa"
    container_name       = "tfstate"
    key                  = "kuksatrng-storage.tfstate"
  }
}