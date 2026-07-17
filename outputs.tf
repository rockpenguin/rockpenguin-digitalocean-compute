output "droplet_a_records" {
  value = {
    for id, data in digitalocean_record.droplet_dns_a : id => data
  }
  description = "Map of Droplet DNS A records"
}

output "droplet_ids_map" {
  value = {
    for key, val in digitalocean_droplet.svr : key => val.id
  }
  description = "Map of Droplet IDs"
}

output "http_load_balancers" {
  value = {
    for id, lb in var.load_balancers : id =>
      length(setintersection(lb.forwarding_rules[*].entry_protocol, ["https","http2","http3"]))
    }
}

output "load_balancers_id_map" {
  value = {
    for key, val in digitalocean_loadbalancer.lb : key => val.id
  }
  description = "Map of LB IDs"
}

output "reserved_ips" {
  value = digitalocean_reserved_ip.rsvp_ip
}
