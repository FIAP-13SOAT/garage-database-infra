########################################
# RDS POSTGRESQL — uma instância por serviço PG
########################################

resource "aws_db_subnet_group" "main" {
    name       = "${local.projectName}-db-subnet-group"
    subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]

    tags = {
        Name = "${local.projectName}-db-subnet-group"
    }
}

resource "aws_db_instance" "postgres" {
    for_each = toset(local.services)

    identifier = "${local.projectName}-${each.key}-postgres"

    engine         = "postgres"
    engine_version = "16.11"
    instance_class = "db.t3.micro"

    allocated_storage = 20
    storage_type      = "gp2"

    db_name                     = "garage_${each.key}"
    username                    = "postgres"
    manage_master_user_password = true

    vpc_security_group_ids = [aws_security_group.rds.id]
    db_subnet_group_name   = aws_db_subnet_group.main.name

    skip_final_snapshot = true

    tags = {
        Name = "${local.projectName}-${each.key}-postgres"
    }
}
