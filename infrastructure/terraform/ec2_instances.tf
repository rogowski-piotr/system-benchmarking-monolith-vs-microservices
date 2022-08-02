# this recource will create a ec2 instance with specified specs
resource "aws_instance" "ec2_instance_WebServer" {
  ami                    = "ami-065deacbcaac64cf2"            # this is a Ubuntu linux ami id
  instance_type          = "INSTANCE_TYPE"                    # this is a secret created in github repo
  # instance_type          = "t2.micro"
  security_groups = [aws_security_group.security_group.name]
  key_name = "admin"
  tags = {
    Name = "WebServer"
  }
}