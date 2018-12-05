output "private_ips" {
  value = ["${oci_core_instance.PilosaInstance.*.private_ip}"]
}

output "public_ips" {
  value = ["${oci_core_instance.PilosaInstance.*.public_ip}"]
}

output "agent_ips" {
  value = ["${oci_core_instance.AgentInstance.*.public_ip}"]
}
