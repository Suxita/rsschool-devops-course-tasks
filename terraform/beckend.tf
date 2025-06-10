terraform {
  backend "s3" {
    bucket = "rsschool-devops-app-bucket-64lc16qi"  
    key    = "terraform/state"
    region = "eu-central-1" 
  }
}