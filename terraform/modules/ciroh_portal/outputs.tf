output "efs_id" {
  value = aws_efs_file_system.efs.id
}
output "aws_eip" {
  value = { for k, v in aws_eip.nat : k => v.id }
}
output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}
