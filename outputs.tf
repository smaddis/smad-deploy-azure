output "kube_config" {
    value = module.k8s_cluster_azure.kube_config
    description = "A 'kube_config' object to be used with kubectl and Helm"
    sensitive   = true
}


output "kubeconfig_path" {
    value = abspath("${path.root}/kubeconfig")
}