# aws-highly-available-web-app

  This project demonstrates the deployment of a highly available and scalable static web application on AWS using a production-style architecture. It is designed to provide high availability, scalability, fault tolerance, secure network isolation, and shared storage while following AWS best practices.

  The solution consists of an Application Load Balancer that distributes incoming traffic across Amazon EC2 instances managed by an Auto Scaling Group within a custom Amazon VPC. Amazon EFS provides persistent shared storage for static assets, while Apache access and error logs are automatically archived to Amazon S3 using a scheduled cron job. The deployment also incorporates IAM roles, public and private subnets, a NAT Gateway, Amazon Machine Images (AMIs), and Launch Templates to create a secure, resilient, and scalable web hosting environment.

# architecture

<img width="1316" height="666" alt="image" src="https://github.com/user-attachments/assets/0287c441-e534-4cec-8e2e-99559e89405b" />

  

  
