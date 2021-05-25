variable "bucket_Name" {
    type = string
    default = ""
}

variable "visibility" {
    type = string
    default = "public"
}

variable "versioning" {
    type = bool
    default = true
}

variable "success_page" {
    type = string
    default = "index.html"
}

variable "error_Page" {
    type = string
    default = "error.html"
}

variable "environment" {
    type = string
    default = ""
}

variable "logs_target_bucket" { 
    type = string
    default = ""
}

variable "logs_target_prefix" {
    type = string
    default = ""
}
