###############################################################################
# LOCALS
###############################################################################
locals {
  lb_droplet_tags = { for id, lb in var.load_balancers : id => lb.droplet_tag }

  # Commented out 2026-07-04 was going to use below code to support automatic
  # certificate creation, but went in a different direction; leaving for the time
  # being for posterity sake because there is some cool shit code
  # ****
  # Let's gather the LBs that use HTTPS/HTTP2/HTTP3 so that we can create certs
  # We'll use "setintersection" to determine if any of the forwarding_rules contain
  # one of the protocols we're looking for
  # http_load_balancers = {
  #   for id, lb in var.load_balancers : id => lb
  #     if length(setintersection(lb.forwarding_rules[*].entry_protocol, ["https","http2","http3"])) > 0
  # }
  # http_forwarding_rules = flatten([ for id, lb in local.http_load_balancers : lb.forwarding_rules ])
  # certificates_create = distinct(
  #   [
  #     for rule_data in local.http_forwarding_rules : rule_data.certificate_name
  #       if rule_data.certificate_create && tobool(length(regexall("http[s23]", rule_data.entry_protocol)) > 0)
  #   ]
  # )
  # ****
}

###############################################################################
# CERTIFICATES for LBs
###############################################################################
resource "digitalocean_certificate" "http_lb_cert" {
  for_each = var.certificates

  name = replace(each.key, "_", "-")
  type = each.value.type
  private_key = each.value.private_key
  leaf_certificate = each.value.leaf_certificate
  certificate_chain = each.value.certificate_chain
  domains = each.value.domains
}

###############################################################################
# LOAD BALANCER FIREWALLS to allow traffic to droplets from LB
# https://docs.digitalocean.com/products/networking/load-balancers/details/features/#http3
###############################################################################
resource "digitalocean_firewall" "lb_firewall" {
  for_each = digitalocean_loadbalancer.lb
  name = each.value.name

  tags = [each.value.name]

  dynamic "inbound_rule" {
    for_each = each.value.forwarding_rule
    content {
      # protocol = contains(["http", "https", "http2", "http3", "tcp"], inbound_rule.value.target_protocol) ? "tcp" : "udp"
      # If the target_protocol is any flavor of HTTP/S/2/3 then the firewall should be TCP, else UDP
      protocol = inbound_rule.value.target_protocol != "udp" ? "tcp" : "udp"
      port_range = inbound_rule.value.target_port
      source_load_balancer_uids = [digitalocean_loadbalancer.lb[each.key].id]
    }
  }

  dynamic "inbound_rule" {
    for_each = each.value.healthcheck
    content {
      protocol = "tcp" # LB health checks only support HTTP(S) or TCP, so firewall protocol will always be TCP
      port_range = inbound_rule.value.port
      source_load_balancer_uids = [digitalocean_loadbalancer.lb[each.key].id]
    }
  }
}

###############################################################################
# LOAD BALANCER TAGS - Auto create a tag for each LB droplet tag
# Need to do this because LB creation will fail if the tag
# doesn't already exist
###############################################################################
resource "digitalocean_tag" "lb_tag" {
  for_each = var.load_balancers
  name = each.value.droplet_tag
}

###############################################################################
# LOAD BALANCER DNS - Adding DNS for HTTP LBs
###############################################################################
resource "digitalocean_record" "lb_dns_a" {
  # ensure DNS naming is enabled and that the domain is valid e.g. ! misspelled
  for_each = {
    for id, lb in var.load_balancers : id => lb
      if lb.dns_enabled && contains(data.digitalocean_domains.all.domains[*].name, lb.dns_domain)
  }
  domain = each.value.dns_domain
  name = each.value.name
  type = "A"
  ttl = 600
  value = digitalocean_loadbalancer.lb[each.key].ip
}

###############################################################################
# LOAD BALANCERS
###############################################################################
resource "digitalocean_loadbalancer" "lb" {
  for_each = var.load_balancers

  type                             = "REGIONAL"
  name                             = each.value.name
  region                           = each.value.region
  size                             = each.value.size
  size_unit                        = each.value.size_unit
  redirect_http_to_https           = each.value.redirect_http_to_https
  enable_proxy_protocol            = each.value.enable_proxy_protocol
  enable_backend_keepalive         = each.value.enable_backend_keepalive
  http_idle_timeout_seconds        = each.value.http_idle_timeout_seconds
  disable_lets_encrypt_dns_records = each.value.disable_lets_encrypt_dns_records
  project_id                       = each.value.project_id
  vpc_uuid                         = each.value.vpc_uuid
  droplet_ids                      = each.value.droplet_ids
  droplet_tag                      = each.value.droplet_tag
  network                          = each.value.network
  network_stack                    = each.value.network_stack
  tls_cipher_policy                = each.value.tls_cipher_policy

  dynamic "forwarding_rule" {
    for_each = each.value.forwarding_rules

    content {
      entry_protocol = forwarding_rule.value["entry_protocol"]
      entry_port = forwarding_rule.value["entry_port"]
      target_protocol = forwarding_rule.value["target_protocol"]
      target_port = forwarding_rule.value["target_port"]
      # require that the LB creation depends on a certificate that already exists
      certificate_name = forwarding_rule.value["certificate_create"] ? digitalocean_certificate.http_lb_cert[forwarding_rule.value["certificate_name"]].name : forwarding_rule.value["certificate_name"]
      tls_passthrough = forwarding_rule.value["tls_passthrough"]
    }
  }

  healthcheck {
    protocol = each.value.healthcheck.protocol
    port = each.value.healthcheck.port
    path = each.value.healthcheck.protocol != "tcp" ? each.value.healthcheck.path : null
    check_interval_seconds = each.value.healthcheck.check_interval_seconds
    response_timeout_seconds = each.value.healthcheck.response_timeout_seconds
    unhealthy_threshold = each.value.healthcheck.unhealthy_threshold
    healthy_threshold = each.value.healthcheck.healthy_threshold
  }

  # sticky_sessions {
  #   type = each.value.sticky_sessions.type
  #   cookie_name = each.value.sticky_sessions.cookie_name
  #   cookie_ttl_seconds = each.value.sticky_sessions.cookie_ttl_seconds
  # }

  # firewall {
  #   deny = each.value.firewall.deny
  #   allow = each.value.firewall.allow
  # }

  ## Global LB settings
  # target_load_balancer_ids = optional(list(string))

  # domains = optional(object({
  #   name = string
  #   is_managed = bool
  #   certificate_name = string
  # }))

  # glb_settings = optional(object({
  #   target_protocol = string
  #   target_port = number
  #   cdn = object({
  #     is_enabled = bool
  #   })
  # }))
  #
}
