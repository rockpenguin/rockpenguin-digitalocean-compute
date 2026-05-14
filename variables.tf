variable "droplets" {
  description = "Droplets definition"
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
    dns_enabled       = optional(bool, false)
    dns_domain        = optional(string)
    ipv6              = optional(bool, false)
  }))
  default = {}
}
