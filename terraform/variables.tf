variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "github_org" {
  description = "GitHub username"
  type        = string
  default     = "Suxita"  
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "rsschool-devops-course-tasks"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "rsschool-devops"
}