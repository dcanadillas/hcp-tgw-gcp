output "gcp_vms" {
  value = [ for i in google_compute_instance.vm : "gcloud compute ssh hashi@${i.name} --zone ${i.zone}"]
}
output "consul_config" {
  value = try(base64decode(data.hcp_consul_cluster.example[0].consul_config_file), null)
}
output "consul_ca_cert" {
  value = try(base64decode(data.hcp_consul_cluster.example[0].consul_ca_file), null)
  sensitive = true
}
output "consul_private_endpoint" {
  value = try(data.hcp_consul_cluster.example[0].consul_private_endpoint_url, null)
}


output "vault_private_endpoint" {
  value = try(data.hcp_vault_cluster.example[0].vault_private_endpoint_url, null)
}