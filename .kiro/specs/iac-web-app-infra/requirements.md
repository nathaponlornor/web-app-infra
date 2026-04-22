# Requirements Document

## Introduction

Infrastructure as Code (IaC) for a web application consisting of a static frontend served via CloudFront with WAF protection, a backend running on ECS with EC2 capacity behind an Application Load Balancer, and an RDS PostgreSQL database. The backend and database reside in private subnets for security isolation.

## Glossary

- **IaC_Module**: The Infrastructure as Code module that defines and provisions all cloud resources for the web application
- **VPC**: The Virtual Private Cloud network that contains all infrastructure resources
- **Frontend_Distribution**: The CloudFront distribution that serves static frontend assets from S3
- **WAF**: The Web Application Firewall that protects the CloudFront distribution from common web exploits
- **S3_Bucket**: The S3 bucket that stores static frontend assets (HTML, CSS, JS, images)
- **ALB**: The Application Load Balancer that distributes traffic to backend ECS tasks
- **ECS_Cluster**: The ECS cluster running on EC2 instances that hosts backend application containers
- **RDS_Instance**: The RDS PostgreSQL database instance storing application data
- **Private_Subnet**: A subnet with no direct internet access, used for backend and database resources
- **Public_Subnet**: A subnet with internet gateway access, used for the ALB and NAT Gateway

## Requirements

### Requirement 1: VPC and Network Infrastructure

**User Story:** As a DevOps engineer, I want a well-structured VPC with public and private subnets, so that I can isolate backend and database resources from direct internet access.

#### Acceptance Criteria

1. THE IaC_Module SHALL create a VPC with a configurable CIDR block
2. THE IaC_Module SHALL create at least two Public_Subnets across different availability zones
3. THE IaC_Module SHALL create at least two Private_Subnets across different availability zones for backend workloads
4. THE IaC_Module SHALL create at least two Private_Subnets across different availability zones for database resources
5. THE IaC_Module SHALL create an Internet Gateway attached to the VPC for public subnet internet access
6. THE IaC_Module SHALL create a NAT Gateway in a Public_Subnet to allow Private_Subnet resources to reach the internet for outbound traffic
7. THE IaC_Module SHALL create route tables that route Public_Subnet traffic through the Internet Gateway and Private_Subnet traffic through the NAT Gateway

### Requirement 2: S3 Static Frontend Hosting

**User Story:** As a DevOps engineer, I want static frontend assets stored in S3, so that the frontend is served reliably and cost-effectively.

#### Acceptance Criteria

1. THE IaC_Module SHALL create an S3_Bucket configured for static website content storage
2. THE IaC_Module SHALL block all public access to the S3_Bucket
3. THE IaC_Module SHALL create an Origin Access Control policy allowing only the Frontend_Distribution to read objects from the S3_Bucket
4. THE IaC_Module SHALL enable server-side encryption on the S3_Bucket

### Requirement 3: CloudFront Distribution

**User Story:** As a DevOps engineer, I want a CloudFront distribution serving the frontend, so that users experience low-latency access to the application globally.

#### Acceptance Criteria

1. THE IaC_Module SHALL create a Frontend_Distribution with the S3_Bucket as its origin
2. THE IaC_Module SHALL configure the Frontend_Distribution to redirect HTTP requests to HTTPS
3. THE IaC_Module SHALL configure the Frontend_Distribution with a default root object of "index.html"
4. THE IaC_Module SHALL associate the WAF web ACL with the Frontend_Distribution

### Requirement 4: WAF Protection

**User Story:** As a DevOps engineer, I want WAF protection on the CloudFront distribution, so that the frontend is protected from common web exploits and bot traffic.

#### Acceptance Criteria

1. THE IaC_Module SHALL create a WAF web ACL scoped for CloudFront
2. THE IaC_Module SHALL configure the WAF with AWS Managed Rules for common threats (AWSManagedRulesCommonRuleSet)
3. THE IaC_Module SHALL configure the WAF with AWS Managed Rules for known bad inputs (AWSManagedRulesKnownBadInputsRuleSet)
4. THE IaC_Module SHALL set the WAF default action to allow requests that do not match any blocking rules

### Requirement 5: Application Load Balancer

**User Story:** As a DevOps engineer, I want an ALB in front of the backend, so that traffic is distributed across ECS tasks with health checking.

#### Acceptance Criteria

1. THE IaC_Module SHALL create an ALB in the Public_Subnets
2. THE IaC_Module SHALL create an ALB target group with health check configuration for the backend service
3. THE IaC_Module SHALL create an ALB listener on port 80 that forwards traffic to the backend target group
4. THE IaC_Module SHALL create a security group for the ALB that allows inbound HTTP traffic on port 80
5. IF HTTPS is required, THEN THE IaC_Module SHALL support an ALB listener on port 443 with a configurable ACM certificate ARN

### Requirement 6: ECS Cluster on EC2

**User Story:** As a DevOps engineer, I want the backend running on ECS with EC2 capacity, so that I have control over instance types and can run containerized workloads.

#### Acceptance Criteria

1. THE IaC_Module SHALL create an ECS_Cluster with EC2 capacity providers
2. THE IaC_Module SHALL create an Auto Scaling Group for EC2 instances in the Private_Subnets
3. THE IaC_Module SHALL configure EC2 instances with the ECS-optimized AMI
4. THE IaC_Module SHALL create an ECS task definition with configurable CPU, memory, and container image
5. THE IaC_Module SHALL create an ECS service that registers tasks with the ALB target group
6. THE IaC_Module SHALL create a security group for ECS instances that allows inbound traffic only from the ALB security group
7. THE IaC_Module SHALL create an IAM instance profile with permissions for EC2 instances to join the ECS_Cluster

### Requirement 7: RDS PostgreSQL Database

**User Story:** As a DevOps engineer, I want an RDS PostgreSQL instance in private subnets, so that application data is stored securely without direct internet exposure.

#### Acceptance Criteria

1. THE IaC_Module SHALL create an RDS_Instance running PostgreSQL engine in the database Private_Subnets
2. THE IaC_Module SHALL create a DB subnet group spanning at least two availability zones
3. THE IaC_Module SHALL create a security group for the RDS_Instance that allows inbound PostgreSQL traffic (port 5432) only from the ECS security group
4. THE IaC_Module SHALL disable public accessibility on the RDS_Instance
5. THE IaC_Module SHALL enable storage encryption on the RDS_Instance
6. THE IaC_Module SHALL configure the RDS_Instance with a configurable instance class, allocated storage, database name, and master username
7. IF a deletion occurs accidentally, THEN THE IaC_Module SHALL protect the RDS_Instance with deletion protection enabled by default

### Requirement 8: Security and IAM

**User Story:** As a DevOps engineer, I want least-privilege IAM roles and security groups, so that each component has only the permissions it needs.

#### Acceptance Criteria

1. THE IaC_Module SHALL create an ECS task execution IAM role with permissions to pull container images and write logs
2. THE IaC_Module SHALL create an ECS task IAM role with no additional permissions by default (extensible by the user)
3. THE IaC_Module SHALL ensure all security groups follow deny-all-inbound by default, with only explicitly required ports opened

### Requirement 9: CI/CD Pipeline with GitHub Actions

**User Story:** As a DevOps engineer, I want a GitHub Actions CI/CD pipeline, so that infrastructure changes are automatically validated on pull requests and deployed on merge to the main branch.

#### Acceptance Criteria

1. THE CI/CD Pipeline SHALL run `terraform fmt -check` and `terraform validate` on every pull request to ensure code quality
2. THE CI/CD Pipeline SHALL run `terraform plan` on every pull request and post the plan output as a PR comment for review
3. THE CI/CD Pipeline SHALL run `terraform apply -auto-approve` when changes are merged to the `main` branch
4. THE CI/CD Pipeline SHALL authenticate to AWS using OpenID Connect (OIDC) federation to avoid storing long-lived credentials
5. THE CI/CD Pipeline SHALL use a remote S3 backend with DynamoDB state locking for Terraform state management
6. THE CI/CD Pipeline SHALL use environment-based variables (e.g., `dev`, `staging`, `prod`) to support multi-environment deployments
7. THE CI/CD Pipeline SHALL cache Terraform provider plugins to speed up workflow execution
8. IF `terraform plan` detects no changes, THEN THE CI/CD Pipeline SHALL skip the apply step and report "No changes detected"
