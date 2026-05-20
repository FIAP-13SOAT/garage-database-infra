########################################
# SSM — PostgreSQL (RDS)
########################################

resource "aws_ssm_parameter" "db_endpoint" {
    for_each = aws_db_instance.postgres

    name      = "/${local.projectName}/prod/${each.key}/db/endpoint"
    type      = "String"
    value     = each.value.endpoint
    overwrite = true
}

resource "aws_ssm_parameter" "db_secret_arn" {
    for_each = aws_db_instance.postgres

    name      = "/${local.projectName}/prod/${each.key}/db/secret_arn"
    type      = "String"
    value     = length(each.value.master_user_secret) > 0 ? each.value.master_user_secret[0].secret_arn : ""
    overwrite = true
}

########################################
# SSM — DocumentDB (execution-service)
########################################

resource "aws_ssm_parameter" "docdb_execution_endpoint" {
    name      = "/${local.projectName}/prod/execution/docdb/endpoint"
    type      = "String"
    value     = aws_docdb_cluster.execution.endpoint
    overwrite = true
}

resource "aws_ssm_parameter" "docdb_execution_secret_arn" {
    name      = "/${local.projectName}/prod/execution/docdb/secret_arn"
    type      = "String"
    value     = aws_secretsmanager_secret.docdb_execution.arn
    overwrite = true
}