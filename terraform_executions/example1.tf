# provider se usa para definir el proveedor de nube , PUEDEN EXISTIR varios bloques de provider = "xx"
# para el caso en que la configuración terraform esté compuesta por multiples proveedores 
provider "aws" {
# el profile hace referencia al archivo de configuracion en %UserProfile%\.aws\credentials
  profile    = "default"
  region     = "sa-east-1"
}

resource "aws_instance" "example1" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}