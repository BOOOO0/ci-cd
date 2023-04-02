resource "aws_vpc" "main"{
	cidr_block = "10.0.0.0/16"
	
	tags = {
		Name = "ci_cd"
	}
}

resource "aws_subnet" "jenkins_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.1.0/24"
	
	availability_zone = "ap-northeast-2a"
	
	tags = {
		Name = "jenkins_server"
	}
}

resource "aws_subnet" "web_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.2.0/24"

	availability_zone = "ap-northeast-2c"

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
	subnet_id = aws_subnet.jenkins_subnet.id
	
	route_table_id = aws_route_table.new_public_rtb.id
}

resource "aws_route_table_association" "web_subnet_association" {
	subnet_id = aws_subnet.web_subnet.id

	route_table_id = aws_route_table.new_public_rtb.id
}
