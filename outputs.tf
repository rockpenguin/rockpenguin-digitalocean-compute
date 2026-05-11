output "droplet_ids_map" {
  value = {
    for key, val in digitalocean_droplet.droplet : key => val.id
  }
}
