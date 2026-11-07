moved {
  from = aws_instance.app-fora
  to   = module.rede.aws_instance.app-fora
}

moved {
  from = aws_iam_instance_profile.app-fora_profile
  to   = module.rede.aws_iam_instance_profile.app-fora_profile
}

moved {
  from = aws_iam_role.app-fora_role
  to   = module.rede.aws_iam_role.app-fora_role
}

moved {
  from = aws_route_table_association.aws_route_table_association_privada_a_rt_privada
  to   = module.rede.aws_route_table_association.aws_route_table_association_privada_a_rt_privada
}

moved {
  from = aws_route_table_association.aws_route_table_association_privada_b_rt_privada
  to   = module.rede.aws_route_table_association.aws_route_table_association_privada_b_rt_privada
}

moved {
  from = aws_route_table_association.aws_route_table_association_publica_a_rt_publica
  to   = module.rede.aws_route_table_association.aws_route_table_association_publica_a_rt_publica
}

moved {
  from = aws_route_table_association.aws_route_table_association_publica_b_rt_publica
  to   = module.rede.aws_route_table_association.aws_route_table_association_publica_b_rt_publica
}

moved {
  from = aws_internet_gateway.igw
  to   = module.rede.aws_internet_gateway.igw
}

moved {
  from = aws_security_group.instance_app-fora_group
  to   = module.rede.aws_security_group.instance_app-fora_group
}

moved {
  from = aws_vpc.principal
  to   = module.rede.aws_vpc.principal
}

moved {
  from = aws_subnet.privada-a
  to   = module.rede.aws_subnet.privada-a
}

moved {
  from = aws_subnet.privada-b
  to   = module.rede.aws_subnet.privada-b
}

moved {
  from = aws_subnet.publica-a
  to   = module.rede.aws_subnet.publica-a
}

moved {
  from = aws_subnet.publica-b
  to   = module.rede.aws_subnet.publica-b
}

moved {
  from = aws_route.route_rt-publica_to_igw_ipv4
  to   = module.rede.aws_route.route_rt-publica_to_igw_ipv4
}

moved {
  from = aws_route_table.rt-privada
  to   = module.rede.aws_route_table.rt-privada
}

moved {
  from = aws_route_table.rt-publica
  to   = module.rede.aws_route_table.rt-publica
}

moved {
  from = aws_security_group_rule.rule_instance_app_fora_group_egress_all_protocols
  to   = module.rede.aws_security_group_rule.rule_instance_app_fora_group_egress_all_protocols
}
