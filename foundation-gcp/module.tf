module "webserver" {
  source       = "../modules/outscale-vm"
  vm_type      = "tinav6.c2r4p1"
  keypair_name = "bastion"
  subnet_id    = data.outscale_subnet.backend_subnet-a.subnet_id
  image_id     = data.outscale_image.image.image_id
  name         = "grafana"
  group        = "grafana"
  env          = "test"
  security_group_ids = [
    data.outscale_security_group.sg-ssh-all-a.security_group_id,
    outscale_security_group.grafana.security_group_id
  ]
}