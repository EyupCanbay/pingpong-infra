resource "vault_mount" "db" {
  path = "database"
  type = "database"
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s_config" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc"
}

# ================================================================
# 🔥 PING SERVICE YAPILANDIRMASI
# ================================================================

# 1. Sadece PingDB'ye giden özel bağlantı
resource "vault_database_secret_backend_connection" "ping_db" {
  backend       = vault_mount.db.path
  name          = "ping-postgres-conn"
  allowed_roles = ["ping-db-role"]

  postgresql {
    connection_url = var.ping_db_connection_url
    username       = var.db_username
    password       = var.db_password
  }
}

resource "vault_database_secret_backend_role" "ping_role" {
  backend             = vault_mount.db.path
  name                = "ping-db-role"
  db_name             = vault_database_secret_backend_connection.ping_db.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT ALL PRIVILEGES ON DATABASE pingdb TO \"{{name}}\";",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
  ]
  default_ttl         = var.ttl_seconds
  max_ttl             = var.max_ttl_seconds
}

resource "vault_policy" "ping_policy" {
  name   = "ping-service-role"
  policy = <<EOT
path "database/creds/ping-db-role" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "ping_app_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "ping-service-role"
  bound_service_account_names      = ["pingpong-app-ping-sa"]
  bound_service_account_namespaces = [var.app_namespace]
  token_policies                   = [vault_policy.ping_policy.name]
  token_ttl                        = 86400
}

# ================================================================
# 🏓 PONG SERVICE YAPILANDIRMASI
# ================================================================

# 2. Sadece PongDB'ye giden özel bağlantı
resource "vault_database_secret_backend_connection" "pong_db" {
  backend       = vault_mount.db.path
  name          = "pong-postgres-conn"
  allowed_roles = ["pong-db-role"]

  postgresql {
    connection_url = var.pong_db_connection_url
    username       = var.db_username
    password       = var.db_password
  }
}

resource "vault_database_secret_backend_role" "pong_role" {
  backend             = vault_mount.db.path
  name                = "pong-db-role"
  db_name             = vault_database_secret_backend_connection.pong_db.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT ALL PRIVILEGES ON DATABASE pongdb TO \"{{name}}\";",
    "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
  ]
  default_ttl         = var.ttl_seconds
  max_ttl             = var.max_ttl_seconds
}

resource "vault_policy" "pong_policy" {
  name   = "pong-service-role"
  policy = <<EOT
path "database/creds/pong-db-role" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "pong_app_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "pong-service-role"
  bound_service_account_names      = ["pingpong-app-pong-sa"]
  bound_service_account_namespaces = [var.app_namespace]
  token_policies                   = [vault_policy.pong_policy.name]
  token_ttl                        = 86400
}