output "aws_sub_zone_id" {
  description = "The AWS Sub Zone ID"
  value = var.create_aws_dns_zone ? aws_route53_zone.aws_sub_zone[0].zone_id : ""
}

output "aws_sub_zone_nameservers" {
  description = "The AWS Sub Zone Name Servers"
  value = var.create_aws_dns_zone ? aws_route53_zone.aws_sub_zone[0].name_servers : []
}

output "azure_sub_zone_name" {
  description = "The Azure Sub Zone Name"
  value = var.create_azure_dns_zone ? azurerm_dns_zone.azure_sub_zone[0].id : ""
}

output "azure_sub_zone_nameservers" {
  description = "The Azure Sub Zone Name Servers"
  value = var.create_azure_dns_zone ? azurerm_dns_zone.azure_sub_zone[0].name_servers : []
}

output "azure_dns_resourcegroup" {
  description = "The Azure Sub Zone resource Group"
  value = var.create_azure_dns_zone ? azurerm_resource_group.dns_resource_group[0].name : ""
}

output "gcp_dns_zone_name" {
  description = "The GCP Sub Zone NAme"
  value = var.create_gcp_dns_zone ? google_dns_managed_zone.gcp_sub_zone[0].name : ""
}

output "gcp_dns_zone_nameservers" {
  description = "The GCP Sub Zone Name Servers"
  value = var.create_gcp_dns_zone ? google_dns_managed_zone.gcp_sub_zone[0].name_servers : []
}
