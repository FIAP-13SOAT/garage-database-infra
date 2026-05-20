########################################
# SECURITY GROUP - RDS (PostgreSQL)
########################################

resource "aws_security_group" "rds" {
    name_prefix = "${local.projectName}-rds-sg"
    vpc_id      = aws_vpc.main.id

    # Allow all traffic from within the VPC (EKS nodes, Lambda, etc.)
    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = [aws_vpc.main.cidr_block]
        description = "Allow PostgreSQL access from within VPC"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${local.projectName}-rds-security-group"
    }
}
