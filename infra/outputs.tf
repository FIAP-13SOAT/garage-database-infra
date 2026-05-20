########################################
# DATABASE OUTPUTS
########################################

output "rds_endpoints" {
    description = "Endpoints PostgreSQL por serviço"
    value       = { for k, v in aws_db_instance.postgres : k => v.endpoint }
}

output "rds_ports" {
    description = "Portas PostgreSQL por serviço"
    value       = { for k, v in aws_db_instance.postgres : k => v.port }
}

output "db_secret_arns" {
    description = "ARNs dos secrets do master user por serviço"
    value       = { for k, v in aws_db_instance.postgres : k => length(v.master_user_secret) > 0 ? v.master_user_secret[0].secret_arn : "" }
}

########################################
# DOCUMENTDB OUTPUTS
########################################

output "docdb_endpoint" {
    description = "Endpoint DocumentDB (MongoDB-compatible) para o execution-service"
    value       = aws_docdb_cluster.execution.endpoint
}

output "docdb_secret_arn" {
    description = "ARN do secret do master user do DocumentDB"
    value       = length(aws_docdb_cluster.execution.master_user_secret) > 0 ? aws_docdb_cluster.execution.master_user_secret[0].secret_arn : ""
}

########################################
# NETWORK OUTPUTS (consumed by garage-cloud-stack)
########################################

output "vpc_id" {
    description = "VPC ID"
    value       = aws_vpc.main.id
}

output "public_subnet_ids" {
    description = "Public subnet IDs"
    value       = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
    description = "Private subnet IDs"
    value       = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]
}
