resource "aws_security_group" "instance_app-fora_group" {
  name                   = "instance_app-fora_group"
  vpc_id                 = module.rede.principal_id
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_app-fora_group"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_app_fora_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_app-fora_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}
