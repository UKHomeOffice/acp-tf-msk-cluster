output "zookeeper_connect_string" {
  description = "A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = coalesce(element(concat(aws_msk_cluster.msk_kafka.*.zookeeper_connect_string, [""]), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.zookeeper_connect_string, [""]), 0))
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = join("", [element(concat(aws_msk_cluster.msk_kafka.*.bootstrap_brokers, [""]), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.bootstrap_brokers, [""]), 0)])
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = coalesce(element(concat(aws_msk_cluster.msk_kafka.*.bootstrap_brokers_tls, [""]), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.bootstrap_brokers_tls, [""]), 0))
}

output "msk_cluster_arn" {
  description = "The MSK cluster arn"
  value       = coalesce(element(concat(aws_msk_cluster.msk_kafka.*.arn, [""]), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.arn, [""]), 0))
}

output "msk_sg_id" {
  description = "The MSK security group ID"
  value       = aws_security_group.sg_msk.id
}