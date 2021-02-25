This module is used create a Azure Key Vault to store
secrets used e.g. in K8S Deployment configurations.
Note that an identity of K8S Kubelet service (kubelet_object_id) 
needs to be allowed read access to the created Key Vault, before 
K8S Deployments can fetch secrets from the vault.

TODO: Document variables
TODO: Document module usage (how to define identities for read access)
TODO: Document outputs
