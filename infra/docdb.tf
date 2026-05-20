########################################
# DOCUMENTDB CLUSTER — banco do garage-execution-service
########################################

resource "random_password" "docdb_execution" {
    length      = 24
    special     = false  # DocDB master password tem restrição de chars; evitar especiais simplifica o URI
    min_lower   = 4
    min_upper   = 4
    min_numeric = 4
}

resource "aws_secretsmanager_secret" "docdb_execution" {
    name                    = "${local.projectName}/execution/docdb/credentials"
    description             = "Master credentials para o DocumentDB do execution-service"
    recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "docdb_execution" {
    secret_id = aws_secretsmanager_secret.docdb_execution.id
    secret_string = jsonencode({
        username = "mongo"
        password = random_password.docdb_execution.result
    })
}

########################################
# SECURITY GROUP — DocumentDB (porta 27017)
########################################

resource "aws_security_group" "docdb" {
    name_prefix = "${local.projectName}-docdb-sg"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 27017
        to_port     = 27017
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main.cidr_block]
        description = "Allow DocumentDB access from within VPC"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${local.projectName}-docdb-security-group"
    }
}

########################################
# DocDB SUBNET GROUP — mesmas subnets privadas do RDS
########################################

resource "aws_docdb_subnet_group" "execution" {
    name       = "${local.projectName}-execution-docdb-subnet-group"
    subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet_b.id]

    tags = {
        Name = "${local.projectName}-execution-docdb-subnet-group"
    }
}

########################################
# DocDB CLUSTER + INSTANCE
########################################

resource "aws_docdb_cluster" "execution" {
    cluster_identifier      = "${local.projectName}-execution-docdb"
    engine                  = "docdb"
    master_username         = "mongo"
    master_password         = random_password.docdb_execution.result
    db_subnet_group_name    = aws_docdb_subnet_group.execution.name
    vpc_security_group_ids  = [aws_security_group.docdb.id]
    skip_final_snapshot     = true
    backup_retention_period = 1
    storage_encrypted       = true

    tags = {
        Name = "${local.projectName}-execution-docdb"
    }
}

resource "aws_docdb_cluster_instance" "execution" {
    identifier         = "${local.projectName}-execution-docdb-1"
    cluster_identifier = aws_docdb_cluster.execution.id
    instance_class     = "db.t3.medium"

    tags = {
        Name = "${local.projectName}-execution-docdb-1"
    }
}
