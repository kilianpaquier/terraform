variable "hostname" {
  type        = string
  description = "Device hostname inside the tailnet"
}

variable "key_expiry_disabled" {
  type        = bool
  default     = false
  description = "Whether to trust the device and disable its key expiration or not"
}

variable "tags" {
  type        = list(string)
  default     = ["tag:terraform"]
  description = "List of tags to affect to the device"
}
