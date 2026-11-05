resource "aws_ssm_parameter" "CloudFrontOutputs" {
  name        = "/cloudfront-lab/cf-outputs"
  data_type   = "text"
  description = "Grouped outputs (distribution domain_name/id, public key id) for the login Lambda to read at runtime instead of hardcoded env vars."
  overwrite   = true
  tier        = "Standard"
  type        = "String"
  value = jsonencode({
    "aws_cloudfront_distribution" = {
      "cdn-protected" = {
        "id"                             = "${aws_cloudfront_distribution.cdn-protected.id}"
        "arn"                            = "${aws_cloudfront_distribution.cdn-protected.arn}"
        "caller_reference"               = "${aws_cloudfront_distribution.cdn-protected.caller_reference}"
        "domain_name"                    = "${aws_cloudfront_distribution.cdn-protected.domain_name}"
        "etag"                           = "${aws_cloudfront_distribution.cdn-protected.etag}"
        "hosted_zone_id"                 = "${aws_cloudfront_distribution.cdn-protected.hosted_zone_id}"
        "in_progress_validation_batches" = "${aws_cloudfront_distribution.cdn-protected.in_progress_validation_batches}"
        "last_modified_time"             = "${aws_cloudfront_distribution.cdn-protected.last_modified_time}"
        "logging_v1_enabled"             = "${aws_cloudfront_distribution.cdn-protected.logging_v1_enabled}"
        "status"                         = "${aws_cloudfront_distribution.cdn-protected.status}"
        "trusted_key_groups"             = "${aws_cloudfront_distribution.cdn-protected.trusted_key_groups}"
        "trusted_signers"                = "${aws_cloudfront_distribution.cdn-protected.trusted_signers}"
      }
    }
    "aws_cloudfront_public_key" = {
      "signing-key-cookies" = {
        "id"               = "${aws_cloudfront_public_key.signing-key-cookies.id}"
        "caller_reference" = "${aws_cloudfront_public_key.signing-key-cookies.caller_reference}"
        "etag"             = "${aws_cloudfront_public_key.signing-key-cookies.etag}"
      }
    }
  })
  tags = {
    Name           = "CloudFrontOutputs"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ssm_parameter" "cf-signing-private-key" {
  name        = "/cloudfront-lab/signing-private-key"
  data_type   = "text"
  description = "RSA private key (SecureString) for CloudFront signed cookies. The login Lambda reads it at runtime to sign the /private policy. Demo/lab only; in production use a rotated secret store, never git."
  overwrite   = false
  tier        = "Standard"
  type        = "SecureString"
  value = <<EOF
-----BEGIN PRIVATE KEY-----
MIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQCpqrtZHIL9fDFU
9PVJPJnqNZRLP0AAuQPFAPzFvp5X7r1R1z5fdVHkgzVODqLdDbhvsmrQ/ZfOfugn
uamGtb9dZzqkOpb1q04rG33LWDTbCZ52GUeuBNOip5v2gCKQbCA4Z7ZfxkxE8URK
I7ORlb+zt6WXsYk5dn4zwbt9sjTvEQOwQAonTQO2w9M3rO4RV+zgf5rLTz9oMqhL
qodAqkya1nQRpWLy9Bl6UcLGKWyfAP+iv7QRgw7a0ShQxSu1snd0mNrqSgHgORsn
iLcO3TbJJeOEgDXzS7xluUcw6ksH+Cflt++vawzkBIMKpvmC/gxXYKMHh72PTSWb
FJq/twbBAgMBAAECgf8eru2qs+lMhkU1pAcn83myTXZAFXQxrUPtQLx11n80T8yV
HGP/R2xD8yaUszjo2S5dpNqEaRgnE/RQGtd5sSyma6DDSoU6cHx2d0ZMm+sTIa4y
lWfNJLpRVBZ0gb++do9tI/RrZaUtYqSC8+npjjdY/QFJaaXzamZwXbzWgn/oK9PT
KKJqRVR3DDOuUOweB16oniokW5+fkeYDig5PjV25/c6cWrXOgxGNFRbZI5F926Ht
gA9IWAJu0cHUxWNUnv3BpS6GqLKlUymzRKgtar226K93oqMu3mUCNY6jvMNNz23t
9i5HzE39fKGgRvdRxjX823Zmn6grpIZjh0jbKAECgYEA5RNzr9Fhqe3X2Nf2nMHj
u8MJJ2EjoYUw1kVjaY9YXC+wrLwlsmmlR/Lmv6KtxpgTxioytMDUaJBiGX0vxOZ/
QhxUazkQdFQefeV4pabhEgzYfW5xMEEUmN32VOBAmZABUPNC0eheOhKG8rk4UkMV
gWdGtlPOMUBQ4QlppPhl3sECgYEAvZvAZVT5dgd1z8+sEeqND1VYUwwLN7G6EzmC
xxYRdTpBf+v6KBYIZujRp9pseM9C79WlWEweTau3A6BdrA7TbVFKvV5McjOXp5LL
eq6Cgzhn3zXk+LQrIcoPekduW55waJXr/voOVw5udo01Hs9MKnNPVc3yFDqqqdPQ
MJBDKAECgYBx2QAG4l3ScVVz/Kkg8S+4ck8LVji6HpLN+wBURxyX/E+nGX72s5Ck
OHE7zqLk71Hsi65VrPwj15YZquDhz9hxR9kgzOSDnAbndPNICK8VJHM3q3rvi3is
HKw/NJCGgU5WKAAOiJjD7c9JtInsQFDg1i4LkY0JZziLDv2FMrqWQQKBgHyFbTUf
OTVqcNSpbjfV8g2/3uGrZzKMZcd6XYih1ZVHTPzV3NO2pI3xGL9DkzlD5JHdnVj/
pGcd/nNDPkFg+zkvygXTiCD4AQDsRvWq5cuHn6/XlShAKpNmQAPuJWvGAcytqO8r
CX/i2mjBE8HIIh0+3TtcpT7jyHD/yhoapAABAoGBAM/jacp2t/4AdLmDZCWmLg+9
2THH31Yomrc3X9iUbckck5wa3Od6kOvyoiVMLo9g7PejHazye5xRf+NasmTDx+hf
lUPKlmEu06uDRLrPYYpbLhHwQP7AvccioCVqV3MRpx5V0nxJzeAv8GZily/BvAS8
9VJANYWVMlOOQOM2H5kz
-----END PRIVATE KEY-----
  EOF
  tags = {
    Name           = "cf-signing-private-key"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}
