output "instance_id" {
  description = "instance id for web server"
  value       = aws_instance.buldr_instance.id
}

output "public_ip" {
  description = "public ip address of web server"
  value       = aws_instance.buldr_instance.public_ip
}
