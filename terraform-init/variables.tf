variable "aws_region" {
    default = "eu-central-1"
    description = "aws provider region"
    type = string
}

variable "user_access_key_id_assume_role" {    
    description = "access key id to allow terraform role"
    type = string
}

variable "state_bucket_name" {
    default = "terraform-remote-state"
    type    = string
    description = "name of state bucket for terraform"
}
    
variable "dynamodb_table_name" {
    default = "terraform-remote-state"
    type    = string
    description = "name of dynamodb lock for terraform"
} 

variable "arn_user" {
    type = string
    description = "arn for trust relation on terraform"
}