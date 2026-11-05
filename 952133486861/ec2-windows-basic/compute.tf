resource "aws_instance" "windows-basic" {
  key_name               = aws_cloudformation_stack.windows-basic-key.outputs["KeyName"]
  subnet_id              = aws_subnet.public-windows-basic.id
  ami                    = "ami-06672fd375c1bfca2"
  iam_instance_profile   = aws_iam_instance_profile.windows-basic_profile.name
  instance_type          = "t3.medium"
  private_ip             = "10.25.1.224"
  vpc_security_group_ids = [aws_security_group.instance_windows-basic_group.id]
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  enclave_options {
    enabled = false
  }
  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    kms_key_id  = "arn:aws:kms:us-west-2:952133486861:key/f019f965-2340-4c77-b976-182a1c3460ab"
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 75
    volume_type = "gp3"
    tags = {
      Name = "windows-basic"
    }
  }
  tags = {
    Name           = "windows-basic"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}
