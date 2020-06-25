resource "aws_efs_file_system" "main" {
  tags = {
    Name = "WordPress on Lambda Main Filesystem"
  }
}

resource "random_string" "namespace" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_efs_access_point" "lambda" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = "/roots/wp-lambda-${random_string.namespace.result}"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }
}

resource "aws_efs_mount_target" "main" {
  for_each = toset(var.subnet_ids)

  file_system_id = aws_efs_file_system.main.id
  subnet_id      = each.value
  security_groups = [
    aws_security_group.efs_access.id
  ]
}
