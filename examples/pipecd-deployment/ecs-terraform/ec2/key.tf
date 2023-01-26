variable "key_name" {
  type        = string
  description = "for fumidai"
  #キーペア名はここで指定
  default = "pipecd-fumidai-local-key"
}

#作成したキーペアを格納するファイルを指定。
locals {
  public_key_file  = "../.key_pair/${var.key_name}.id_rsa.pub"
  private_key_file = "../.key_pair/${var.key_name}.id_rsa"
}

#privateキーのアルゴリズム設定
resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#local_fileのリソースを指定するとterraformを実行するディレクトリ内でファイル作成やコマンド実行が出来る。
resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_openssh" {
  filename = local.public_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.keygen.public_key_openssh
}