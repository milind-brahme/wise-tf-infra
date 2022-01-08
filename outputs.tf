output "public_ip" {
  description = "Public IP address assigned to the host by EC2"
  value       = aws_instance.amzLinuxMilind.public_ip
}