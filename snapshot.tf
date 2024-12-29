#Создание снимка
resource "yandex_compute_snapshot" "vm1" {
  name           = "vm1-snapshot"
  source_disk_id = yandex_compute_instance.vm1.boot_disk.0.disk_id
}

resource "yandex_compute_snapshot" "vm2" {
  name           = "vm2-snapshot"
  source_disk_id = yandex_compute_instance.vm2.boot_disk.0.disk_id
}

resource "yandex_compute_snapshot" "bastion" {
  name           = "bastion-snapshot"
  source_disk_id = yandex_compute_instance.bastion.boot_disk.0.disk_id
}

resource "yandex_compute_snapshot" "elastic" {
  name           = "elastic-snapshot"
  source_disk_id = yandex_compute_instance.elastic.boot_disk.0.disk_id
}

resource "yandex_compute_snapshot" "kibana" {
  name           = "kibana-snapshot"
  source_disk_id = yandex_compute_instance.kibana.boot_disk.0.disk_id
}

resource "yandex_compute_snapshot" "zabbix" {
  name           = "zabbix-snapshot"
  source_disk_id = yandex_compute_instance.zabbix.boot_disk.0.disk_id
}

#Создание расписания
resource "yandex_compute_snapshot_schedule" "schedule" {
  name = "schedule"

  schedule_policy {
    expression = "0 1 * * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "Время жизни"
  }

  disk_ids = [yandex_compute_instance.vm1.boot_disk.0.disk_id, 
              yandex_compute_instance.vm2.boot_disk.0.disk_id, 
              yandex_compute_instance.bastion.boot_disk.0.disk_id,
              yandex_compute_instance.elastic.boot_disk.0.disk_id,
              yandex_compute_instance.kibana.boot_disk.0.disk_id,
              yandex_compute_instance.zabbix.boot_disk.0.disk_id]

  depends_on = [yandex_compute_instance.vm1,
                yandex_compute_instance.vm2,
                yandex_compute_instance.bastion,
                yandex_compute_instance.elastic,
                yandex_compute_instance.kibana,
                yandex_compute_instance.zabbix]   
}