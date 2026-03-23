########################################
# DATABASE OUTPUTS
########################################

output "rds_endpoint" {
    description = "Endpoint do banco PostgreSQL"
    value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
    description = "Porta do banco PostgreSQL"
    value       = aws_db_instance.postgres.port
}

output "db_secret_arn" {
    description = "ARN do secret contendo a senha do banco PostgreSQL"
    value       = length(aws_db_instance.postgres.master_user_secret) > 0 ? aws_db_instance.postgres.master_user_secret[0].secret_arn : ""
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
