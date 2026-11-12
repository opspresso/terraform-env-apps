# The key of the SecureString Variables of this account's targets (the eb target's secretsKeyArn). Agent Runway encrypts
# with it through its secrets role, and each instance decrypts its own environment's values; both only through SSM.
# The default key policy lets those IAM policies decide. Deleting the key loses every stored secret Variable.
resource "aws_kms_key" "variables" {
  description             = "Agent Runway Variables of the eb targets in this account"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "variables" {
  name          = "alias/agent-runway"
  target_key_id = aws_kms_key.variables.key_id
}
