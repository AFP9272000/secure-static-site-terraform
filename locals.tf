locals {
  # Centralised tag set applied to every resource. You can extend this map
  # through the project_tags variable to include values such as cost centre,
  # owner or environment.
  common_tags = var.project_tags
}