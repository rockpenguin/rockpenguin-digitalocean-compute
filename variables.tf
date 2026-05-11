variable "droplets" {
  description = "Droplets definition"
  type = map(object({
    image   = string
    name    = string
    region  = string
    size    = string
    backups = optional(bool, false)
    backup_policy = optional(object({
      plan    = string
      weekday = string
      hour    = number
    }))
    droplet_agent = optional(bool, true)
    monitoring = optional(bool, false)
    ssh_keys = list(string)
    tags = optional(list(string))
    user_data = optional(string)
    volume_ids = optional(list(string))
    vpc_uuid = string
    public_networking = optional(bool)
    ipv6 = optional(bool, false)
  }))
  default = {}
}
