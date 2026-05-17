########################################
# DOCUMENTDB (MongoDB-compatible) — execution-service
########################################

resource "aws_docdb_subnet_group" "main" {
    name       = "${local.projectName}-docdb-subnet-group"
    subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]

    tags = {
        Name = "${local.projectName}-docdb-subnet-group"
    }
}

resource "aws_docdb_cluster" "execution" {
    cluster_identifier     = "${local.projectName}-execution-docdb"
    engine                 = "docdb"
    db_subnet_group_name   = aws_docdb_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.docdb.id]

    master_username             = "mongo"
    manage_master_user_password = true

    skip_final_snapshot = true

    tags = {
        Name = "${local.projectName}-execution-docdb"
    }
}

resource "aws_docdb_cluster_instance" "execution" {
    identifier         = "${local.projectName}-execution-docdb-instance"
    cluster_identifier = aws_docdb_cluster.execution.id
    instance_class     = "db.t3.medium"

    tags = {
        Name = "${local.projectName}-execution-docdb-instance"
    }
}

########################################
# RDS POSTGRESQL — demais serviços
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
