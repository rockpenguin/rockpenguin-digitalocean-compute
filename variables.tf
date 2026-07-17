###############################################################################
# CERTIFICATES - create certificates for HTTP* load balancers
###############################################################################
variable "certificates" {
  description = "Certificates definitions"
  type = map(object({
    type = optional(string, "lets_encrypt")
    private_key = optional(string)
    leaf_certificate = optional(string)
    certificate_chain = optional(string)
    domains = optional(list(string))
  }))
  default = {}
}

###############################################################################
# DROPLETS
###############################################################################
variable "droplets" {
  description = "Droplets definitions"
  type = map(object({
    image           = string
    name            = string
    region          = string
    size            = string

    backups_enabled = optional(bool, false)
    backup_policy   = optional(object({
      plan    = string
      weekday = string
      hour    = number
    }))

    droplet_agent     = optional(bool, true)
    monitoring        = optional(bool, false)
    ssh_keys          = list(string)
    tags              = optional(list(string))
    user_data         = optional(string)
    volume_ids        = optional(list(string))
    vpc_uuid          = optional(string)
    public_networking = optional(bool)
    # reserved_ip_name  = optional(string)
    dns_enabled       = optional(bool, false)
    dns_domain        = optional(string)
    ipv6              = optional(bool, false)
  }))
  default = {}
}

###############################################################################
# DROPLET RESERVED IPs
###############################################################################
variable "reserved_ips" {
  description = "Reserved IP addresses"
  type = map(object({
    region = string
    droplet_name = optional(string)
  }))
}

###############################################################################
# FIREWALLS
###############################################################################
variable "firewalls" {
  description = "Firewall definitions"
  type = map(object({
    name = string
    ingress_rules = optional(list(object({
      protocol = string
      port_range = string
      source_addresses = optional(list(string))
      source_tags = optional(list(string))
      source_load_balancer_uids = optional(list(string))
      source_kubernetes_ids = optional(list(string))
    })), [])
    egress_rules = optional(list(object({
      protocol = string
      port_range = string
      destination_addresses = optional(list(string))
      destination_tags = optional(list(string))
      destination_load_balancer_uids = optional(list(string))
      destination_kubernetes_ids = optional(list(string))
    })), [])
  }))
  default = {}
}

###############################################################################
# LOAD BALANCERS
###############################################################################
variable "load_balancers" {
  description = "Load balancers"
  type = map(object({
    name                              = string
    region                            = string
    size                              = optional(string)
    size_unit                         = optional(number)
    redirect_http_to_https            = optional(bool)
    enable_proxy_protocol             = optional(bool)
    enable_backend_keepalive          = optional(bool)
    http_idle_timeout_seconds         = optional(number)
    disable_lets_encrypt_dns_records  = optional(bool, true)
    project_id                        = optional(string)
    vpc_uuid                          = optional(string)
    droplet_ids                       = optional(list(string))
    droplet_tag                       = optional(string)

    type                              = optional(string, "REGIONAL")
    network                           = optional(string)
    network_stack                     = optional(string)
    tls_cipher_policy                 = optional(string)

    dns_enabled                       = optional(bool, false)
    dns_domain                        = optional(string)

    forwarding_rules = list(object({
      entry_protocol     = string
      entry_port         = number
      target_protocol    = string
      target_port        = number
      certificate_name   = optional(string)
      certificate_create = optional(bool, false)
      tls_passthrough    = optional(bool, false)
    }))

    healthcheck = optional(object({
      protocol                 = string
      port                     = number
      path                     = optional(string)
      check_interval_seconds   = optional(number, 10)
      response_timeout_seconds = optional(number, 5)
      unhealthy_threshold      = optional(number, 3)
      healthy_threshold        = optional(number, 5)
    }))

    sticky_sessions = optional(object({
      type = string
      cookie_name = string
      cookie_ttl_seconds = number
    }))

    firewall = optional(object({
      deny = list(string)
      allow = list(string)
    }))

    ## Global LB settings
    target_load_balancer_ids = optional(list(string))

    domains = optional(object({
      name = string
      is_managed = bool
      certificate_name = string
    }))

    glb_settings = optional(object({
      target_protocol = string
      target_port = number
      cdn = object({
        is_enabled = bool
      })
    }))
  }))
  default = {}
}
