variable "environment" {
    default = "development"
}

variable "location" {
    default = "West Europe"
}

variable "project_name" {
    default = "kuksatrng"
}


variable "name" {
  type        = string
  description = "The name of the Azure Key Vault"
  default     = "standard"
}

variable "sku_name" {
  type        = string
  description = "Select Standard or Premium SKU"
  default     = "standard"
}

# Configuration for a Default Azure Key Vault access policy with Admin permissions
# Grants all actions to all keyvault object types.
# This policy must be kept for a proper run of the "terraform destroy" process
variable "kv-key-permissions-full" {
    type        = list(string)
    description = <<-EOT
                    List of full key permissions, must be one or more 
                    from the following:
                    "backup, create, decrypt, delete, encrypt, get, 
                    import, list, purge, recover, restore, sign, unwrapKey, 
                    update, verify, wrapKey".
                    EOT
    default     = [ "backup", "create", "decrypt", "delete", "encrypt", 
                    "get", "import", "list", "purge", "recover", "restore", 
                    "sign", "unwrapKey","update", "verify", "wrapKey" ]
}

variable "kv-secret-permissions-full" {
    type        = list(string)
    description = <<-EOT
                    List of full secret permissions, must be one or more 
                    from the following:
                    "backup, delete, get, list, purge, recover, 
                    restore, set".
                    EOT
    default     = [ "backup", "delete", "get", "list",
                    "purge", "recover", "restore", "set" ]
} 

variable "kv-certificate-permissions-full" {
    type        = list(string)
    description = <<-EOT
                    List of full certificate permissions, must be one or more 
                    from the following:
                    "backup, create, delete, deleteissuers, get, 
                    getissuers, import, list, listissuers, managecontacts, 
                    manageissuers, purge, recover, restore, setissuers, update".
                    EOT
    default     = [ "create", "delete", "deleteissuers", "get", 
                    "getissuers", "import", "list", "listissuers", 
                    "managecontacts", "manageissuers", "purge", 
                    "recover", "setissuers", "update", "backup", "restore" ]
}

variable "kv-storage-permissions-full" {
    type        = list(string)
    description = <<-EOT
                    List of full storage permissions, must be one or more 
                    from the following:
                    "backup, delete, deletesas, get, getsas, list, listsas, 
                    purge, recover, regeneratekey, restore, set, setsas, update".
                    EOT
    default     = [ "backup", "delete", "deletesas", "get", "getsas",
                    "list", "listsas", "purge", "recover", "regeneratekey", 
                    "restore", "set", "setsas", "update" ]
}

# Configuration for various Azure Key Vault READ access policies
variable "kv-key-permissions-read" {
    type        = list(string)
    description = "List of read key permissions."
    default     = [ "get", "list" ]
}

variable "kv-secret-permissions-read" {
  type        = list(string)
  description = "List of read secret permissions."
  default     = [ "get", "list" ]
} 

variable "kv-certificate-permissions-read" {
  type        = list(string)
  description = "List of read certificate permissions."
  default     = [ "get", "getissuers", "list", "listissuers" ]
}

variable "kv-storage-permissions-read" {
  type        = list(string)
  description = "List of read storage permissions."
  default     = [ "get", "getsas", "list", "listsas" ]
}

# You create these in the main.tf calling this keyvault-module.
# Possible values for *_permission keys are described above.
# Note: You can make direct references to the variables above, 
#       e.g. "secret_permissions = var.kv-secret-permissions-read".
# Example usage in main.tf:
# # module "keyvault" {
# #     policies = {
# #         full_permission = {
# #           tenant_id               = var.azure-tenant-id     ## CUSTOMIZE THIS
# #           object_id               = var.kv-full-object-id   ## CUSTOMIZE THIS
# #           key_permissions         = var.kv-key-permissions-full
# #           secret_permissions      = var.kv-secret-permissions-full
# #           certificate_permissions = var.kv-certificate-permissions-full
# #           storage_permissions     = var.kv-storage-permissions-full
# #         }
# #         read_permission = {
# #         tenant_id               = var.azure-tenant-id       ## CUSTOMIZE THIS
# #         object_id               = var.kv-read-object-id     ## CUSTOMIZE THIS
# #         key_permissions         = var.kv-key-permissions-read
# #         secret_permissions      = var.kv-secret-permissions-read
# #         certificate_permissions = var.kv-certificate-permissions-read
# #         storage_permissions     = var.kv-storage-permissions-read
# #         }
# #     }
# # }
variable "policies" {
  type = map(object({
    tenant_id               = string
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
    storage_permissions     = list(string)
  }))
  description = "Define a Azure Key Vault access policy"
  default = {}
}
