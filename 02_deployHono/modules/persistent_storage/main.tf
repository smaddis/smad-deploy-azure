resource "kubernetes_secret" "storage_secret" {
  metadata {
    name = "storage-auth"
  }

  data = {
    name                    = var.storage_acc_name
    azurestorageaccountname = var.storage_acc_name
    primary_access_key      = var.storage_acc_key
    azurestorageaccountkey  = var.storage_acc_key
  }

  type = "Opaque"
}

resource "kubernetes_storage_class" "azure_file_retain" {
  metadata {
    name = "azure-file-retain"
  }
  storage_provisioner = "kubernetes.io/azure-file"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  parameters = {
    kind            = "managed"
    cachingMode     = "ReadOnly"
    resourceGroup   = var.separate_storage_rg_name
    storage_account = var.storage_acc_name
  }
}

resource "kubernetes_persistent_volume_claim" "mongopvc" {
  metadata {
    name = "mongopvc"
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.azure_file_retain.metadata.0.name
    resources {
      requests = {
        storage = "8Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.mongo_volume.metadata.0.name
  }
}

resource "kubernetes_persistent_volume_claim" "influxpvc" {
  metadata {
    name = "influxpvc"
    #    annotations = "volume.beta.kubernetes.io/storage-class: """
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.azure_file_retain.metadata.0.name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.influx_volume.metadata.0.name
  }
}
resource "kubernetes_persistent_volume_claim" "kafkapvc" {
  metadata {
    name = "kafkapvc"
    #    annotations = "volume.beta.kubernetes.io/storage-class: """
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.azure_file_retain.metadata.0.name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.kafka_volume.metadata.0.name
  }
}
resource "kubernetes_persistent_volume_claim" "zookeeperpvc" {
  metadata {
    name = "zookeeperpvc"
    #    annotations = "volume.beta.kubernetes.io/storage-class: """
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.azure_file_retain.metadata.0.name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.zookeeper_volume.metadata.0.name
  }
}

resource "kubernetes_persistent_volume" "influx_volume" {
  metadata {
    name = "influxpvc"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    storage_class_name               = kubernetes_storage_class.azure_file_retain.metadata.0.name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      azure_file {
        secret_name = kubernetes_secret.storage_secret.metadata.0.name
        share_name  = var.storage_share_influx
      }
    }
  }
}

resource "kubernetes_persistent_volume" "mongo_volume" {
  metadata {
    name = "mongopvc"
  }
  spec {
    capacity = {
      storage = "8Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    storage_class_name               = kubernetes_storage_class.azure_file_retain.metadata.0.name
    persistent_volume_reclaim_policy = "Retain"
    mount_options = ["dir_mode=0777",
      "file_mode=0777",
      "uid=1001",
      "gid=1001",
      "mfsymlinks",
    "nobrl"]
    persistent_volume_source {
      azure_file {
        secret_name = kubernetes_secret.storage_secret.metadata.0.name
        share_name  = var.storage_share_mongo
      }
    }
  }
}

resource "kubernetes_persistent_volume" "kafka_volume" {
  metadata {
    name = "kafkapvc"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    storage_class_name               = kubernetes_storage_class.azure_file_retain.metadata.0.name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      azure_file {
        secret_name = kubernetes_secret.storage_secret.metadata.0.name
        share_name  = var.storage_share_kafka
      }
    }
  }
}
resource "kubernetes_persistent_volume" "zookeeper_volume" {
  metadata {
    name = "zookeeperpvc"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    storage_class_name               = kubernetes_storage_class.azure_file_retain.metadata.0.name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      azure_file {
        secret_name = kubernetes_secret.storage_secret.metadata.0.name
        share_name  = var.storage_share_zookeeper
      }
    }
  }
}

resource "kubernetes_storage_class" "azure-disk-retain" {
  metadata {
    name = "azure-disk-retain"
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  parameters = {
    kind        = "managed"
    cachingMode = "ReadOnly"
    #  resourceGroup = var.use_separate_storage_rg ? "storage-resource-group" : null
  } # implicitly create storage class in the same RG as K8S cluster if false ^^^
}

resource "kubernetes_persistent_volume_claim" "mongodb-data" {
  metadata {
    name = "mongodb-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
    storage_class_name = "azure-disk-retain"
  }
}
