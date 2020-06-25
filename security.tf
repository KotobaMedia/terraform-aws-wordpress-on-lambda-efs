resource "aws_security_group" "efs_access" {
  name_prefix = "wponlambda_efs_"
  description = "Allow EFS access from Lambda for WordPress on Lambda"
  vpc_id      = data.aws_subnet.first.vpc_id
}

resource "aws_security_group_rule" "efs_access_efs" {
  security_group_id = aws_security_group.efs_access.id
  
  type      = "ingress"
  from_port = 2049
  to_port   = 2049
  protocol  = "tcp"
  self      = true
}