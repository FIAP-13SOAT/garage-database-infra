########################################
# MongoDB self-hosted no EC2 (AWS Academy não permite DocumentDB)
#
# - 1 instância EC2 t3.small em subnet privada
# - Volume EBS gp3 de 20GB anexado em /var/lib/mongodb
# - User_data instala mongo 7, configura auth e cria usuários no 1º boot
# - SSM expõe a connection string completa (SecureString) para o cloud-stack
########################################

data "aws_ami" "amazon_linux_2023" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["al2023-ami-2023*-x86_64"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "random_password" "mongo_root" {
    length  = 24
    special = false
}

resource "random_password" "mongo_app" {
    length  = 24
    special = false
}

locals {
    mongo_app_database = "execution"
    mongo_app_user     = "garage"
}

resource "aws_instance" "mongo" {
    ami                    = data.aws_ami.amazon_linux_2023.id
    instance_type          = "t3.small"
    subnet_id              = aws_subnet.private_subnet.id
    vpc_security_group_ids = [aws_security_group.mongo.id]

    user_data_replace_on_change = true
    user_data = templatefile("${path.module}/templates/mongo_userdata.sh.tftpl", {
        root_password = random_password.mongo_root.result
        app_database  = local.mongo_app_database
        app_user      = local.mongo_app_user
        app_password  = random_password.mongo_app.result
    })

    root_block_device {
        volume_size = 10
        volume_type = "gp3"
        encrypted   = true
    }

    tags = {
        Name = "${local.projectName}-mongo"
    }
}

resource "aws_ebs_volume" "mongo_data" {
    availability_zone = aws_instance.mongo.availability_zone
    size              = 20
    type              = "gp3"
    encrypted         = true

    tags = {
        Name = "${local.projectName}-mongo-data"
    }
}

resource "aws_volume_attachment" "mongo_data" {
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.mongo_data.id
    instance_id = aws_instance.mongo.id

    # Não destacar automaticamente — força destroy explícito do volume
    stop_instance_before_detaching = true
}
