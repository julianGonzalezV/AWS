# provider se usa para definir el proveedor de nube , PUEDEN EXISTIR varios bloques de provider = "xx"
# para el caso en que la configuración terraform esté compuesta por multiples proveedores 
provider "aws" {
# el profile hace referencia al archivo de configuracion en %UserProfile%\.aws\credentials
  profile    = "default"
  region     = "sa-east-1"
}

# New resource for the S3 bucket our application will use.
resource "aws_s3_bucket" "example" {
  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.
  bucket = "terraform-getting-started-guide"
  acl    = "private"
}


resource "aws_instance" "example1" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
  depends_on = [aws_s3_bucket.example]
}

resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance.example1.id
}