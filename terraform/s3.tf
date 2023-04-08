resource "aws_s3_bucket" "key_bucket" {
	bucket = "sshbucket-0408"

	tags = {
		Name = "sshbucket-0408"
	}
}
