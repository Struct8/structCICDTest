variable "secret_recovery_days" {
  type        = number
  default     = 0
  description = "Days a deleted secret can still be restored. 0 deletes it at once, so a test can recreate it with the same name. Use 7 to 30 in production."
}
