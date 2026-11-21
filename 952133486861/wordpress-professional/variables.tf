variable "alarm_email" {
  type        = string
  default     = "rbpmconsulting@gmail.com"
  description = "Required. Address that receives the CloudWatch alarms of the site. AWS sends a confirmation message to it after the apply, and alarms arrive only after the subscription is confirmed.\nImportant: the compile refuses an example.com address."
}

variable "allow_data_loss" {
  type        = bool
  default     = true
  description = "When true, a destroy deletes the Aurora cluster without a final snapshot and empties the media bucket. Use false in production."
}

variable "app_min_instances" {
  type        = number
  default     = 1
  description = "Minimum number of EC2 instances of the WordPress cluster. 1 costs less in a test. Use 2 in production, so the tasks run in both Availability Zones."
}
