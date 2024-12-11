output "hostname" {
  value = aws_db_instance.database.address
}

output "dbname" {
  value = replace(var.prefix, "-", "")
}

