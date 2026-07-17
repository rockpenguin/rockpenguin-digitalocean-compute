###############################################################################
# LOCALS
###############################################################################
locals {
  # create a list of droplet tags to check against firewall names; need to
  # flatten because otherwise it creates a list of lists :-)
  # droplet_firewall_tags = flatten([for id,droplet in var.droplets : droplet.tags])
}

###############################################################################
# DATA Resources
###############################################################################

# DOMAINS - Get the list of DO hosted domains so we can check Droplets' DNS
data "digitalocean_domains" "all" {}

###############################################################################
# DROPLETS
###############################################################################
resource "digitalocean_droplet" "svr" {
  for_each = var.droplets

  image   = each.value.image
  name    = each.value.name
  region  = each.value.region
  size    = each.value.size
  backups = each.value.backups_enabled
  dynamic "backup_policy" {
    # If backups = false then make this an empty map
    for_each = each.value.backups_enabled ? each.value.backup_policy : {}
    content {
      plan    = each.value.backup_policy.plan
      weekday = each.value.backup_policy.weekday
      hour    = each.value.backup_policy.hour
    }
  }
  droplet_agent     = each.value.droplet_agent
  monitoring        = each.value.monitoring
  ssh_keys          = each.value.ssh_keys
  tags              = each.value.tags
  user_data         = each.value.user_data
  volume_ids        = each.value.volume_ids
  vpc_uuid          = each.value.vpc_uuid
  public_networking = each.value.public_networking
  ipv6              = each.value.ipv6
}

###############################################################################
# DROPLET DNS - Adding DNS for Droplets
###############################################################################
resource "digitalocean_record" "droplet_dns_a" {
  # ensure DNS naming is enabled and that the domain is valid e.g. ! misspelled
  for_each = {
    for id, droplet in var.droplets : id => droplet
      if droplet.dns_enabled && contains(data.digitalocean_domains.all.domains[*].name, droplet.dns_domain)
  }
  domain = each.value.dns_domain
  name = each.value.name
  type = "A"
  ttl = 600
  value = digitalocean_droplet.svr[each.key].ipv4_address
}

###############################################################################
# DROPLET RESERVED IPs
###############################################################################
resource "digitalocean_reserved_ip" "rsvp_ip" {
  for_each = var.reserved_ips

  region = each.value.region
  droplet_id = each.value.droplet_name != null ? digitalocean_droplet.svr[each.value.droplet_name].id : null
}

###############################################################################
# FIREWALL-RELATED TAGS - Auto create a tag for each firewall name
# Need to do this because firewall creation will fail if the tag
# doesn't already exist
###############################################################################
resource "digitalocean_tag" "firewall_tag" {
  for_each = var.firewalls
  name = each.value.name
}

###############################################################################
# FIREWALLS
###############################################################################
resource "digitalocean_firewall" "firewall" {
  for_each = var.firewalls

  name = each.value.name # replace( each.key, "_", "-" ) # Ensure that the firewall name doesn't contain underscores
  tags = [digitalocean_tag.firewall_tag[each.key].name]

  dynamic "inbound_rule" {
    for_each = var.firewalls[each.key].ingress_rules
    content {
      protocol = inbound_rule.value.protocol
      port_range = inbound_rule.value.port_range
      source_addresses = inbound_rule.value.source_addresses
    }
  }

  dynamic "outbound_rule" {
    for_each = var.firewalls[each.key].egress_rules
    content {
      protocol = outbound_rule.value.protocol
      port_range = outbound_rule.value.port_range
      destination_addresses = outbound_rule.value.destination_addresses
    }
  }
}
