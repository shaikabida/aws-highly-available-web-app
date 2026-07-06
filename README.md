# AWS-Highly-Available-Web-App

  This project demonstrates the deployment of a highly available and scalable static web application on AWS using a production-style architecture. It is designed to provide high availability, scalability, fault tolerance, secure network isolation, and shared storage while following AWS best practices.

  The solution consists of an Application Load Balancer that distributes incoming traffic across Amazon EC2 instances managed by an Auto Scaling Group within a custom Amazon VPC. Amazon EFS provides persistent shared storage for static assets, while Apache access and error logs are automatically archived to Amazon S3 using a scheduled cron job. The deployment also incorporates IAM roles, public and private subnets, a NAT Gateway, Amazon Machine Images (AMIs), and Launch Templates to create a secure, resilient, and scalable web hosting environment.

# Architecture

<img width="1320" height="650" alt="image" src="https://github.com/user-attachments/assets/089a16be-9a9a-49af-bf71-a72f9b50665f" />

# AWS Services Used
| AWS Service  | Purpose |
|--------------|---------|
| Amazon VPC               | Provides an isolated virtual network for the application infrastructure. |
| Public & Private Subnets | Segregates internet-facing and application resources across two Availability Zones. |
| Internet Gateway         | Enables internet access for resources in the public subnets. |
| NAT Gateway              | Allows EC2 instances in private subnets to securely access the internet for outbound traffic. |
| Bastion Host             | Provides secure SSH access to EC2 instances in private subnets. |
| Security Groups          | Controls inbound and outbound network traffic between AWS resources. |
| Amazon EC2 | Hosts the Apache web server serving the static website. |
| Amazon Machine Image (AMI) | Stores the pre-configured EC2 image used to launch identical web server instances. |
| Launch Template | Defines the EC2 launch configuration, including the AMI, instance type, security groups, and IAM role. |
| Auto Scaling Group | Automatically launches and terminates EC2 instances based on application demand. |
| Application Load Balancer (ALB) | Distributes incoming HTTP requests across healthy EC2 instances. |
| Target Group | Routes requests from the ALB to registered EC2 instances and performs health checks. |
| Amazon EFS | Provides persistent shared storage for website images mounted at `/var/www/html/img`. |
| Amazon S3 | Stores Apache access and error logs uploaded automatically by a scheduled cron job. |
| IAM Role | Grants EC2 instances secure permission to upload logs to Amazon S3 without using access keys. |



  

  
