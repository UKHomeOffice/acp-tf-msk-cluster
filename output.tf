output "zookeeper_connect_string" {
  description = "A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster"
  value       = "${aws_msk_cluster.msk_kafka.zookeeper_connect_string}"
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = "${aws_msk_cluster.msk_kafka.bootstrap_brokers}"
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = "${aws_msk_cluster.msk_kafka.bootstrap_brokers_tls}"
}

output "msk_cluster_arn" {
  description = "The MSK cluster arn"
  value       = "${element(concat(aws_msk_cluster.msk_kafka.*.arn, list("")), 0)}"
}
