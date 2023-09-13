locals {
  tags = merge(var.tags, { ModuleName = "terraform-azure-kubernetes-cluster" }, { ModuleVersion = "1.0.4" })
}
