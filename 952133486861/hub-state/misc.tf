resource "terraform_data" "seed_hub-image" {
  triggers_replace = ["${path.module}/.external_modules/struct8-hub/image", "latest"]
  lifecycle {
    replace_triggered_by = [aws_ecr_repository.hub-image]
  }
  depends_on = [aws_ecr_repository.hub-image]
  provisioner "local-exec" {
    command = <<EOF
set -e
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.hub-image.repository_url)[0]}
[ "$(uname -m)" = x86_64 ] || [ -e /proc/sys/fs/binfmt_misc/qemu-x86_64 ] || docker run --privileged --rm tonistiigi/binfmt:qemu-v10.2.3@sha256:400a4873b838d1b89194d982c45e5fb3cda4593fbfd7e08a02e76b03b21166f0 --install amd64
docker build --provenance=false --platform linux/amd64 -t ${aws_ecr_repository.hub-image.repository_url}:latest ${path.module}/.external_modules/struct8-hub/image
docker push ${aws_ecr_repository.hub-image.repository_url}:latest
    EOF
    interpreter = ["/bin/bash", "-c"]
  }
}
