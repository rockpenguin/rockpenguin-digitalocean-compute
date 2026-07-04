# TODO #

- [X] Add DNS naming functionality
- [X] Add outputs for Droplet DNS/IP mappings
- [X] Build up README documentation
- [X] Add Load Balancers
- [X] Rename module to `rockpenguin-digitalocean-compute` to more accurately reflect API
- [X] Move firewall resource into this module to reflect API; this will allow easier integration with LBs and Droplets
- [ ] Ensure that *all* resource names do not contain underscores; e.g. see firewall resource
- [ ] Maybe set a var for DNS default TTLs for droplets and LBs
- [X] LOAD BALANCERS: Auto create certs when entry protocol is HTTPS, HTTP2, or HTTP3
- [X] LOAD BALANCERS: Make sure we auto create tags for LBs
- [X] LOAD BALANCERS: See if we can do SAN names for LB certs; will also need to create CNAME records
- [ ] LOAD BALANCERS: Add LBs of type NETWORK
- [ ] LOAD BALANCERS: Add LBs of type GLOBAL
