##########
# DNS Managed Zone
##########

resource "google_dns_managed_zone" "dns_zone" {
  project     = var.gcp_project_id
  name        = local.zone_name
  dns_name    = "${var.zone_dns_name}."
  description = local.zone_description
  labels      = var.zone_labels
  dnssec_config {
    state = "on"
  }
}

##########
# Parent DNS Delegation
##########

data "google_dns_managed_zone" "parent_dns_zone" {
  count   = local.enable_parent_delegation ? 1 : 0
  project = var.parent_zone_project_id # TODO Update this to default to current project
  name    = var.parent_zone_name
}

resource "google_dns_record_set" "ns_delegation_record" {
  count        = local.enable_parent_delegation ? 1 : 0
  project      = var.parent_zone_project_id # TODO Update this to default to current project
  managed_zone = data.google_dns_managed_zone.parent_dns_zone[0].name
  name         = google_dns_managed_zone.dns_zone.dns_name
  type         = "NS"
  rrdatas      = google_dns_managed_zone.dns_zone.name_servers
  ttl          = 3600
}

##########
# DNS Domain Level Records
# These are records not owned by any one service but are needed in the domain
##########

# This is the records for the domain itself (no subdomain)
resource "google_dns_record_set" "domain_record" {
  for_each = {
    for record in var.domain_records :
    "${record.type}" => record
  }

  project      = var.gcp_project_id
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = google_dns_managed_zone.dns_zone.dns_name
  type         = each.value.type
  rrdatas      = each.value.data
  ttl          = each.value.ttl
}

resource "google_dns_record_set" "subdomain_record" {
  for_each = {
    for record in var.subdomain_records :
    "${record.type}-${record.name}" => record
  }

  project      = var.gcp_project_id
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "${each.value.name}.${google_dns_managed_zone.dns_zone.dns_name}"
  type         = each.value.type
  rrdatas      = each.value.data
  ttl          = each.value.ttl
}