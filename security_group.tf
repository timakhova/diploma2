#Бастион - группа безопасности
resource "yandex_vpc_security_group" "bastion-public-sg" {
  name        = "bastion-internal-sg"
  description = "Бастион - группа безопасности"
  network_id  = yandex_vpc_network.net-main.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "Ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#Балансировщик - группа безопасности
resource "yandex_vpc_security_group" "balancer-sg" {
  name        = "balancer-sg"
  description = "Балансировщик - группа безопасности"
  network_id  = yandex_vpc_network.net-main.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP protocol"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "Ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "ANY"
    description       = "Health checks from NLB"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#Забикс - группа безопасности
resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  description = "Забикс - группа безопасности"
  network_id  = yandex_vpc_network.net-main.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP protocol"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Забикс агент"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10050
  }

  ingress {
    protocol       = "TCP"
    description    = "Забикс агент"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }

  ingress {
    protocol       = "ICMP"
    description    = "Ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#Кибана - группа безопасности
resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  description = "Кибана - группа безопасности"
  network_id  = yandex_vpc_network.net-main.id

  ingress {
    protocol       = "TCP"
    description    = "allow 5601"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "Ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    protocol       = "ANY"
    description    = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#Внутренняя - группа безопасности
resource "yandex_vpc_security_group" "private-sg" {
  name        = "private-sg"
  description = "Внутренняя - группа безопасности"
  network_id  = yandex_vpc_network.net-main.id

  ingress {
    protocol        = "ANY"
    description     = "ANY"
	  v4_cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    protocol        = "ANY"
    description     = "ANY"
    v4_cidr_blocks  = ["0.0.0.0/0"]
  }
}