output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}
