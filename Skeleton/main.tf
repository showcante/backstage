provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "vpc_teste" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "Public_Subnet" {
    vpc_id = aws_vpc.vpc_teste.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-Public-subnet"
    }
}

resource "aws_internet_gateway" "cliente-igw" {
    vpc_id = aws_vpc.vpc_teste.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.vpc_teste.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.cliente-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}


resource "aws_security_group" "allow_ssh" {
    name = "Acesso SSH"
    description = "Permitir acesso SSH na maquina"
    vpc_id = aws_vpc.vpc_teste.id

    ingress  {
        
        description      = "SSH para maquina de teste"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
       
    }


    egress  {
        
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    

    tags = {
        Name = "Permitir SSH"
    }
}

resource "aws_instance" "linux_teste" {
    ami = var.image_name
    instance_type = var.instance_type
    subnet_id = aws_subnet.Public_Subnet.id
    availability_zone = var.avail_zone
    key_name = "backstage_test"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    tags  = {
        Name = "${var.env_prefix}-backstage"
    }
}

output "ip" {
    value = "IP para acessar a EC2 '${aws_instance.linux_teste.public_ip}'"
}