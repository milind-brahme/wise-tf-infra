variable "ami_image_id" {
  description = "amazon image id"
  type = string
  default = "ami-002068ed284fb165b"

}

variable "instance_size" {
    description = "aws instance type"
    type = string
    default = "t2.micro"
  
}

variable "key_name" {
  description = "existing key created in AWS"
  type = string
  default = "milndaws2021"
}

variable "osuser" {
    description = "Login user for ami"
    type = string
    default = "ec2-user"
}

variable "path_to_private_key"{
    description = "Path to private key  "
    type = string
    default = "/Users/milindbrahme/milindaws2021.pem"
}