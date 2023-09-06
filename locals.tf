locals {
  tags = merge(var.tags, { ModuleName = "terraform-azure-kubernetes-cluster" }, { ModuleVersion = "5.1.2" })
}
