output "droplet_ids_map" {
  value = {
    for key, val in digitalocean_droplet.droplet : key => val.id
  }
  description = "Map of Droplet IDs"
}

output "droplet_a_records" {
  value = {
    for id, data in digitalocean_record.droplet_dns_a : id => data
  }
  description = "Map of Droplet DNS A records"
}
