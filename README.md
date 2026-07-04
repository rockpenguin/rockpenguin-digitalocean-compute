# rockpenguin-digitalocean-compute

Official Rockpenguin Technology OpenTofu module for DigitalOcean Compute resources. Attempts to simplify creation of compute-related resources. Highly opinionated and tailored to my own needs :-)

**Notable functionality:**
- Can automatically create DNS A records for Droplets and load balancers
- Auto-generate tags for Droplets
- Automatically create Lets Encrypt certificates for HTTPS/HTTP2/HTTP3 load balancer forwarding rules; Note that this module doesn't support BYO certs
- Automatically create firewall rules for Droplets that allow specific traffic from load balancers; based on forwarding rules and health checks

## Requirements

| Name | Version |
| ---- | ------- |
| digitalocean | ~> 2 |

## Providers

| Name | Version |
| ---- | ------- |
| digitalocean | ~> 2 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [digitalocean_certificate.http_lb_cert](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/certificate) | resource |
| [digitalocean_droplet.droplet](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_firewall.firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_firewall.lb_firewall](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_loadbalancer.lb](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer) | resource |
| [digitalocean_record.droplet_dns_a](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_record.lb_dns_a](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record) | resource |
| [digitalocean_tag.firewall_tag](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/tag) | resource |
| [digitalocean_tag.lb_tag](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/tag) | resource |
| [digitalocean_domains.all](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| certificates | Certificates definitions | <pre>map(object({<br/>    type = optional(string, "lets_encrypt")<br/>    private_key = optional(string)<br/>    leaf_certificate = optional(string)<br/>    certificate_chain = optional(string)<br/>    domains = optional(list(string))<br/>  }))</pre> | `{}` | no |
| droplets | Droplets definitions | <pre>map(object({<br/>    image           = string<br/>    name            = string<br/>    region          = string<br/>    size            = string<br/><br/>    backups_enabled = optional(bool, false)<br/>    backup_policy   = optional(object({<br/>      plan    = string<br/>      weekday = string<br/>      hour    = number<br/>    }))<br/><br/>    droplet_agent     = optional(bool, true)<br/>    monitoring        = optional(bool, false)<br/>    ssh_keys          = list(string)<br/>    tags              = optional(list(string))<br/>    user_data         = optional(string)<br/>    volume_ids        = optional(list(string))<br/>    vpc_uuid          = optional(string)<br/>    public_networking = optional(bool)<br/>    dns_enabled       = optional(bool, false)<br/>    dns_domain        = optional(string)<br/>    ipv6              = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| firewalls | Firewall definitions | <pre>map(object({<br/>    name = string<br/>    ingress_rules = optional(list(object({<br/>      protocol = string<br/>      port_range = string<br/>      source_addresses = optional(list(string))<br/>      source_tags = optional(list(string))<br/>      source_load_balancer_uids = optional(list(string))<br/>      source_kubernetes_ids = optional(list(string))<br/>    })), [])<br/>    egress_rules = optional(list(object({<br/>      protocol = string<br/>      port_range = string<br/>      destination_addresses = optional(list(string))<br/>      destination_tags = optional(list(string))<br/>      destination_load_balancer_uids = optional(list(string))<br/>      destination_kubernetes_ids = optional(list(string))<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| load\_balancers | Load balancers | <pre>map(object({<br/>    name                              = string<br/>    region                            = string<br/>    size                              = optional(string)<br/>    size_unit                         = optional(number)<br/>    redirect_http_to_https            = optional(bool)<br/>    enable_proxy_protocol             = optional(bool)<br/>    enable_backend_keepalive          = optional(bool)<br/>    http_idle_timeout_seconds         = optional(number)<br/>    disable_lets_encrypt_dns_records  = optional(bool, true)<br/>    project_id                        = optional(string)<br/>    vpc_uuid                          = optional(string)<br/>    droplet_ids                       = optional(list(string))<br/>    droplet_tag                       = optional(string)<br/><br/>    type                              = optional(string, "REGIONAL")<br/>    network                           = optional(string)<br/>    network_stack                     = optional(string)<br/>    tls_cipher_policy                 = optional(string)<br/><br/>    dns_enabled                       = optional(bool, false)<br/>    dns_domain                        = optional(string)<br/><br/>    forwarding_rules = list(object({<br/>      entry_protocol     = string<br/>      entry_port         = number<br/>      target_protocol    = string<br/>      target_port        = number<br/>      certificate_name   = optional(string)<br/>      certificate_create = optional(bool, false)<br/>      tls_passthrough    = optional(bool, false)<br/>    }))<br/><br/>    healthcheck = optional(object({<br/>      protocol                 = string<br/>      port                     = number<br/>      path                     = optional(string)<br/>      check_interval_seconds   = optional(number, 10)<br/>      response_timeout_seconds = optional(number, 5)<br/>      unhealthy_threshold      = optional(number, 3)<br/>      healthy_threshold        = optional(number, 5)<br/>    }))<br/><br/>    sticky_sessions = optional(object({<br/>      type = string<br/>      cookie_name = string<br/>      cookie_ttl_seconds = number<br/>    }))<br/><br/>    firewall = optional(object({<br/>      deny = list(string)<br/>      allow = list(string)<br/>    }))<br/><br/>    ## Global LB settings<br/>    target_load_balancer_ids = optional(list(string))<br/><br/>    domains = optional(object({<br/>      name = string<br/>      is_managed = bool<br/>      certificate_name = string<br/>    }))<br/><br/>    glb_settings = optional(object({<br/>      target_protocol = string<br/>      target_port = number<br/>      cdn = object({<br/>        is_enabled = bool<br/>      })<br/>    }))<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| droplet\_a\_records | Map of Droplet DNS A records |
| droplet\_ids\_map | Map of Droplet IDs |
| http\_load\_balancers | n/a |
| load\_balancers\_id\_map | Map of LB IDs |


## TODO
Always more to be added! See [TODO](TODO.md)
