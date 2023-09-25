locals {
  tags = merge(
    var.tags,
    {
      ModuleName    = "terraform-azure-kubernetes-cluster",
      ModuleVersion = "6.0.1",
    }
  )
}
