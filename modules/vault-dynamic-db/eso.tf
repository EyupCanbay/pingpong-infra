resource "vault_mount" "kv" {
    path = "secret" 
    type = "kv-v2"
    description = "Static secrets for ESO"  
}

resource "vault_kv_secret_v2" "grafana_admin" {
    mount = vault_mount.kv.path
    name = "monitoring/grafana"
    data_json = jsonencode({
        admin-user     = "admin"
        admin-password = var.grafana_admin_password
  })
}

resource "vault_kv_secret_v2" "alertmanager_slack" {
  mount     = vault_mount.kv.path
  name      = "monitoring/alertmanager"
  data_json = jsonencode({
    slack-webhook-url = var.slack_webhook_url
  })
}

resource "vault_policy" "eso_monitoring" {
  name   = "eso-monitoring-policy"
  policy = <<EOT
path "secret/data/monitoring/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "eso_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets-operator"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]
  token_policies                   = [vault_policy.eso_monitoring.name]
  token_ttl                        = 3600
}