output "web1-private-ip" {
  value = yandex_compute_instance.vm1.network_interface.0.ip_address
}

output "web2-private-ip" {
  value = yandex_compute_instance.vm2.network_interface.0.ip_address
}

output "elasticsearch-private-ip" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}

output "zabbix-public-ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "kibana-public-ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "bastion-host-public-ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}