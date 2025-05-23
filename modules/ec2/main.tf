locals {
  name = "${var.environment}-${var.project_name}-${var.instance_name}"
}
resource "aws_instance" "example" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups
  monitoring             = var.monitoring
  subnet_id              = var.subnet_id
  iam_instance_profile = var.iam_instance_profile
  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}

resource "null_resource" "user_data_exec" {
  count = var.use_null_resource_for_userdata && var.user_data != null ? 1 : 0

  connection {
    type        = "ssh"
    user        = var.remote_exec_user
    private_key = var.private_key
    host        = aws_instance.example.public_ip
  }

  provisioner "remote-exec" {
    inline = [var.user_data]
  }

  depends_on = [aws_instance.example]
}