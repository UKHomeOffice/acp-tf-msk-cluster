output "zookeeper_connect_string" {
  description = "A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = "${coalesce(element(concat(aws_msk_cluster.msk_kafka.*.zookeeper_connect_string, list("")), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.zookeeper_connect_string, list("")), 0))}"
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = "${join("", [element(concat(aws_msk_cluster.msk_kafka.*.bootstrap_brokers, list("")), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.bootstrap_brokers, list("")), 0)])}"
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = "${coalesce(element(concat(aws_msk_cluster.msk_kafka.*.bootstrap_brokers_tls, list("")), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.bootstrap_brokers_tls, list("")), 0))}"
}

output "msk_cluster_arn" {
  description = "The MSK cluster arn"
  value       = "${coalesce(element(concat(aws_msk_cluster.msk_kafka.*.arn, list("")), 0), element(concat(aws_msk_cluster.msk_kafka_with_config.*.arn, list("")), 0))}"
}
