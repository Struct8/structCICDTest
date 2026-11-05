resource "aws_cloudformation_stack" "windows-secure-key" {
  name          = "struct8-keypair-windows-secure-key"
  template_body = jsonencode({ Resources = { KeyPair = { Type = "AWS::EC2::KeyPair", Properties = { KeyName = "windows-secure-key", KeyType = "rsa", KeyFormat = "pem" } } }, Outputs = { KeyName = { Value = { Ref = "KeyPair" } }, KeyPairId = { Value = { "Fn::GetAtt" = ["KeyPair", "KeyPairId"] } } } })
  tags = {
    Name           = "windows-secure-key"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}
