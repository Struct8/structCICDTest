resource "aws_cloudformation_stack" "windows-basic-key" {
  name          = "struct8-keypair-windows-basic-key"
  template_body = jsonencode({ Resources = { KeyPair = { Type = "AWS::EC2::KeyPair", Properties = { KeyName = "windows-basic-key", KeyType = "rsa", KeyFormat = "pem" } } }, Outputs = { KeyName = { Value = { Ref = "KeyPair" } }, KeyPairId = { Value = { "Fn::GetAtt" = ["KeyPair", "KeyPairId"] } } } })
  tags = {
    Name           = "windows-basic-key"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}
