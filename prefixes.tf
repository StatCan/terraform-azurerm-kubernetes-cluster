module "azure_resource_prefixes" {
  source = "git::https://gitlab.k8s.cloud.statcan.ca/cloudnative/platform/terraform/terraform-statcan-azure-cloud-native-resource-prefixes.git?ref=v1.x"

  name_attributes = var.azure_resource_attributes
}
