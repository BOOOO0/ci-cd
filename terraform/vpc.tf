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
