###############################################################################
# DROPLETS
###############################################################################

resource "digitalocean_droplet" "droplet" {
  for_each = var.droplets

  image   = each.value.image
  name    = each.value.name
  region  = each.value.region
  size    = each.value.size
  backups = each.value.backups
  dynamic "backup_policy" {
    # If backups = false then make this an empty map
    for_each = each.value.backups ? each.value.backup_policy : {}
    content {
      plan    = each.value.backup_policy.plan
      weekday = each.value.backup_policy.weekday
      hour    = each.value.backup_policy.hour
    }
  }
  droplet_agent = each.value.droplet_agent
  monitoring = each.value.monitoring
  ssh_keys = each.value.ssh_keys
  tags = each.value.tags
  user_data = each.value.user_data
  volume_ids = each.value.volume_ids
  vpc_uuid = each.value.vpc_uuid
  public_networking = each.value.public_networking
  ipv6 = each.value.ipv6
}
