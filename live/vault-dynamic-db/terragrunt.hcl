terraform {
  source = "../../modules/vault-dynamic-db"
}

inputs = {
  # Vault PingDB'ye doğrudan bağlanır
  ping_db_connection_url = "postgresql://{{username}}:{{password}}@pingpong-app-postgres.pingpong.svc.cluster.local:5432/pingdb?sslmode=disable"
  
  # Vault PongDB'ye doğrudan bağlanır
  pong_db_connection_url = "postgresql://{{username}}:{{password}}@pingpong-app-postgres.pingpong.svc.cluster.local:5432/pongdb?sslmode=disable"
  
  db_username        = "dbuser"
  db_password        = "dbpass"
  
  app_namespace      = "pingpong" 
  ttl_seconds        = 60
  max_ttl_seconds    = 60

  grafana_admin_password = "DENEMEşifresi124578!"
  slack_webhook_url      = "https://hooks.slack.com/services/T000/B000/XXX"
}