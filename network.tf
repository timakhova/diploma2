#Сеть - главная и маршрутизация
resource "yandex_vpc_network" "net-main" {
  name           = "net-main"
  description    = "Общая сеть"
}

resource "yandex_vpc_gateway" "nat-gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name = "route-table"
  network_id = yandex_vpc_network.net-main.id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat-gateway.id
    
  }
}

#Веб сервер 1
resource "yandex_vpc_subnet" "private-vm1" {
  name           = "private-vm1"
  description    = "Сеть ВМ1 зона 1"
  v4_cidr_blocks = ["10.128.10.0/24"]
  zone           = "ru-central1-a"
  network_id = yandex_vpc_network.net-main.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

#Веб сервер 2
resource "yandex_vpc_subnet" "private-vm2" {
  name           = "private-vm2"
  description    = "Сеть ВМ2 зона 2"
  v4_cidr_blocks = ["10.128.20.0/24"]
  zone           = "ru-central1-b"
  network_id = yandex_vpc_network.net-main.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

#Внутренняя сеть
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  description    = "Внутренняя"
  v4_cidr_blocks = ["10.128.30.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net-main.id
  route_table_id = yandex_vpc_route_table.route_table.id
}

#Внешняя сеть
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  description    = "Внешняя"
  v4_cidr_blocks = ["10.128.40.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net-main.id
}

#Целевая группа веб серверов
resource "yandex_alb_target_group" "target-group" {
  name = "target-group"

  target {
    subnet_id = yandex_vpc_subnet.private-vm1.id
    ip_address = yandex_compute_instance.vm1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.private-vm2.id
    ip_address = yandex_compute_instance.vm2.network_interface.0.ip_address
  }
}

#Backend группа
resource "yandex_alb_backend_group" "backend-group" {
  name                     = "backend-group"
  
  http_backend {
    name                   = "http-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.target-group.id]
    load_balancing_config {
      panic_threshold      = 90
    }
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

#HTTP-роутер
resource "yandex_alb_http_router" "http-router" {
  name          = "http-router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name                    = "virtual-host"
  http_router_id          = yandex_alb_http_router.http-router.id
  route {
    name                  = "route"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.backend-group.id
        timeout           = "60s"
      }
    }
  }
}

#Балансировщик
resource "yandex_alb_load_balancer" "balancer" {
  name        = "balancer"
  network_id  = yandex_vpc_network.net-main.id
  security_group_ids = [yandex_vpc_security_group.balancer-sg.id, yandex_vpc_security_group.private-sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.private.id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}