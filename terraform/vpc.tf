data "aws_availability_zones" "available" {
	state	= "available"
}

resource "aws_vpc" "main"{
	cidr_block		= "10.0.0.0/16"

	enable_dns_hostnames	= true
	enable_dns_support	= true

	tags = {
		Name = "ci_cd"
	}
}

resource "aws_subnet" "jenkins_subnet" {
	vpc_id			= aws_vpc.main.id
	cidr_block		= "10.0.1.0/24"
	
	availability_zone	= "ap-northeast-2a"

	map_public_ip_on_launch	= true

	tags = {
		Name = "jenkins_server"
	}
}

resource "aws_subnet" "web_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.2.0/24"

	availability_zone = "ap-northeast-2c"

	map_public_ip_on_launch	= true

	tags = {
		Name = "web_server"
	}
}

resource "aws_internet_gateway" "new_igw" {
	vpc_id = aws_vpc.main.id

	tags = {
		Name = "new-igw"
	}
}

resource "aws_route_table" "new_public_rtb" {
	vpc_id = aws_vpc.main.id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.new_igw.id
	}
	
	tags = {
		Name = "new-public-rtb"
	}
}

resource "aws_route_table_association" "jenkins_subnet_association" {
	subnet_id 	= aws_subnet.jenkins_subnet.id
	route_table_id	= aws_route_table.new_public_rtb.id
}

resource "aws_route_table_association" "web_subnet_association" {
	subnet_id	= aws_subnet.web_subnet.id
	route_table_id	= aws_route_table.new_public_rtb.id
}

resource "aws_instance" "jenkins" {
	ami 			= "ami-04cebc8d6c4f297a3"
	instance_type 		= "t2.micro"
	subnet_id		= aws_subnet.jenkins_subnet.id
	vpc_security_group_ids	= [aws_security_group.my_sg.id]
	key_name		= "jenkins_server_key"
	
	tags = {
		Name = "jenkins_instance"
	}
}

resource "aws_instance" "web_server" {	
	ami 			= "ami-04cebc8d6c4f297a3"	
	instance_type 		= "t2.micro"
	subnet_id		= aws_subnet.web_subnet.id
	vpc_security_group_ids	= [aws_security_group.my_sg.id]
	key_name		= "web_server_key"

	tags = {
		Name = "web_server_instance"
	}
}

resource "aws_security_group" "my_sg" {
	name = var.security_group_name
	vpc_id = aws_vpc.main.id
	
	ingress {
		from_port	= 80
		to_port		= 80
		protocol	= "tcp"
		cidr_blocks	= ["0.0.0.0/0"]
	}
	ingress {
		from_port	= 22
		to_port		= 22
		protocol	= "tcp"
		cidr_blocks	= ["192.168.0.0/32"]
	}
	
	egress {
		from_port	= 0
		to_port		= 0
		protocol	= "-1"
		cidr_blocks	= ["0.0.0.0/0"]
	}

	tags = {
		Name = "my_ci_cd_sg"
	}
}

variable "security_group_name" {
	description	= "The name of the security group"
	type		= string
	default		= "my_ci_cd_sg"
}

output "jenkins_public_ip" {
	value		= aws_instance.jenkins.public_ip
	description	= "The public IP of jenkins server instance"
}

output "jenkins_private_ip" {
	value		= aws_instance.jenkins.private_ip
	description	= "The private IP of jenkins server instance"
}

output "web_server_public_ip" {
	value		= aws_instance.web_server.public_ip
	description	= "The public IP of web server instance"
}

output "web_server_private_ip" {
	value		= aws_instance.web_server.private_ip
	description	= "The private IP of web server instance"
}
