variable "project_id" {
  description = "STACKIT project ID under which the object storage bucket and credentials are created."
  type        = string
}

variable "bucket_name" {
  description = "Name of the STACKIT object storage bucket. Must be globally unique across all STACKIT projects."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3–63 characters, start and end with a lowercase letter or digit, and contain only lowercase letters, digits, or hyphens."
  }
}

variable "credentials_name" {
  description = "Name of the STACKIT object storage credentials group created for programmatic access to the bucket."
  type        = string
}
