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
# SSM — MongoDB (EC2)
########################################

resource "aws_ssm_parameter" "mongo_endpoint" {
    name      = "/${local.projectName}/prod/garage-execution-service/mongo/endpoint"
    type      = "String"
    value     = aws_instance.mongo.private_ip
    overwrite = true
}

resource "aws_ssm_parameter" "mongo_url" {
    name      = "/${local.projectName}/prod/garage-execution-service/mongo_url"
    type      = "SecureString"
    overwrite = true
    value = format(
        "mongodb://%s:%s@%s:27017/%s?authSource=%s",
        local.mongo_app_user,
        random_password.mongo_app.result,
        aws_instance.mongo.private_ip,
        local.mongo_app_database,
        local.mongo_app_database,
    )
}
