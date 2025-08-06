terraform {
  backend "s3" {
    bucket         = "neel-terraform-state-bucket"
    key            = "eks/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
