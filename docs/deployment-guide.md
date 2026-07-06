# Deployment Guide

## Step 1: Configure the Networking Infrastructure

### 1.1 Create the VPC

Created a custom Amazon VPC named **`cafe-vpc`** with the CIDR block **`172.16.0.0/16`**.

**Reference:** `images/networking/1. vpc.png`


### 1.2 Create Public and Private Subnets

Created two public and two private subnets across two Availability Zones to provide high availability.

| Subnet Name | CIDR Block | Availability Zone | Type |
|-------------|------------|-------------------|------|
| cafe-pub-subnet-1 | 172.16.1.0/24 | us-east-1a | Public |
| cafe-pub-subnet-2 | 172.16.2.0/24 | us-east-1b | Public |
| cafe-priv-subnet-1 | 172.16.15.0/24 | us-east-1a | Private |
| cafe-priv-subnet-2 | 172.16.16.0/24 | us-east-1b | Private |

Enabled **Auto-assign Public IPv4 Address** for both public subnets to allow internet connectivity for public resources.

**References:**
- `images/networking/2. public-subnet-1.png`
- `images/networking/3. public-subnet-2.png`
- `images/networking/4. private-subnet-1.png`
- `images/networking/5. private-subnet-2.png`


### 1.3 Configure Internet Gateway

Created an Internet Gateway named **`cafe-IGW`** and attached it to **`cafe-vpc`** to provide internet access for resources deployed in the public subnets.

**Reference:** `images/networking/6. internet-gateway.png`


### 1.4 Configure Public Route Table

Created a public route table named **`cafe-pub-RT`**.

Configured the following routes:

| Destination | Target |
|-------------|--------|
| 172.16.0.0/16 | Local |
| 0.0.0.0/0 | Internet Gateway (`cafe-IGW`) |

Associated the route table with:

- `cafe-pub-subnet-1`
- `cafe-pub-subnet-2`

**References:**
- `images/networking/7. public-route-table-1.png`
- `images/networking/7. public-route-table-2.png`
- `images/networking/7. public-route-table-3.png`


### 1.5 Configure NAT Gateway

Allocated an Elastic IP address and created a NAT Gateway in **`cafe-pub-subnet-2`** to provide outbound internet access for instances deployed in the private subnets.

**References:**
- `images/networking/8. NAT-gateway.png`
- `images/networking/9. elastic-ip`


### 1.6 Configure Private Route Table

Created a private route table named **`cafe-priv-RT`**.

Configured the following routes:

| Destination | Target |
|-------------|--------|
| 172.16.0.0/16 | Local |
| 0.0.0.0/0 | NAT Gateway |

Associated the route table with:

- `cafe-priv-subnet-1`
- `cafe-priv-subnet-2`

**References:**
- `images/networking/10. private-route-table-1.png`
- `images/networking/10. private-route-table-2.png`
- `images/networking/10. private-route-table-3.png`
  
---
## Step 2: Configure Security

### 2.1 Create Security Groups

Created separate Security Groups for each AWS resource to control inbound and outbound network traffic.

| Security Group | Purpose |
|----------------|---------|
| cafe-bastion-sg | Allows SSH (TCP 22) access only from my public IP address. |
| cafe-alb-sg | Allows HTTP traffic from the internet to the Application Load Balancer. |
| cafe-instances-sg | Allows HTTP traffic from the ALB and SSH access from the Bastion Host. |
| cafe-efs-sg | Allows NFS (TCP 2049) access from the web server instances. |

**References:**
- `images/security/1. sg-bastion.png`
- `images/security/2. sg-alb.png`
- `images/security/3. sg-alb.png`
- `images/security/4. sg-efs.png`


### 2.2 Deploy the Bastion Host

Launched a Bastion Host in **`cafe-pub-subnet-1`** to securely reach EC2 instances deployed in the private subnets.

Configured the instance with the **`cafe-bastion-sg`** Security Group, allowing SSH access only from my public IP address. The Bastion Host acts as the entry point for managing instances that do not have public IP addresses.

**References:**
- `images/security/5. bastion-host.png`

---

## Step 3: Configure Shared Storage

### 3.1 Create the Amazon EFS File System

Created an Amazon Elastic File System named **`cafe-images`** to provide persistent shared storage for website images across all EC2 instances.

**Reference:** `images/storage/1. EFS.png`

- 
### 3.2 Create an EFS Access Point

Created an EFS Access Point to provide a consistent mount path and simplify access to the shared file system from EC2 instances.

**Reference:** images/storage/2. access-point.png`


### 3.3 Configure Automatic Mounting

Configured the EC2 User Data script to automatically:

- Install the required packages (`amazon-efs-utils`).
- Create the mount directory at **`/var/www/html/img`**.
- Add the EFS mount entry to **`/etc/fstab`** using the EFS Access Point.
- Mount the file system automatically using `mount -a`.

The mount was configured through EC2 User Data, allowing every instance launched from the Launch Template to automatically connect to the shared file system during startup.

**References:**
- `docs/scripts/userdata.sh`
- `images/storage/3. fstab.png`

---
## Step 4: Deploy the Web Application

### 4.1 Launch the EC2 Instance

Launched an Amazon EC2 instance in **`cafe-priv-subnet-1`** using the **`cafe-instances-sg`** Security Group.

This instance was configured as the web server and later used to create the Amazon Machine Image (AMI) for the Auto Scaling Group.

**Reference:** `images/compute/1. instance.png`


### 4.2 Configure the Web Server

Configured the EC2 User Data script to automatically:

- Install Apache HTTP Server and the required packages.
- Create the mount directory for Amazon EFS.
- Mount the Amazon EFS file system.
- Clone the Wave Cafe static website from GitHub.
- Copy the website files to **`/var/www/html`**.
- Start and enable the Apache service.

This ensures every instance launched from the Launch Template is automatically configured without manual intervention.

**Reference:**  `docs/scripts/userdata.sh`

---
## Step 5: Configure Automated Log Archival

### 5.1 Create the Amazon S3 Bucket

Created an Amazon S3 bucket named **`cafe-web-access-logs`** to store Apache access and error logs generated by the web server instances.

**Reference:** `images/logging/1. s3-bucket.png`


### 5.2 Create and Attach an IAM Role

Created an IAM role with **AmazonS3FullAccess** permissions and attached it to the EC2 instance. This allowed the instance to securely upload log files to Amazon S3 without using access keys.

**Reference:** `images/logging/2. iam-role.png`


### 5.3 Configure Automated Log Upload

Created a shell script to automate the upload of Apache **`access_log`** and **`error_log`** files to the Amazon S3 bucket. The script organizes logs into hostname-based folders with timestamped filenames and clears the local log files after a successful upload.

**References:**
- `docs/scripts/web_logs_s3.sh`
- `images/logging/4. logs-s3.png`
- `images/logging/5. logs-s3.png`


### 5.4 Schedule the Log Upload

Configured a cron job to execute the log upload script at regular intervals, ensuring that Apache logs are automatically archived to Amazon S3 without manual intervention.

**References:** `images/logging/6. cronjob.png`

---
## Step 6: Create the Amazon Machine Image and Launch Template

### 6.1 Create the Amazon Machine Image

Created an Amazon Machine Image (AMI) named **`cafe-AMI-with-s3`** from the configured EC2 instance after completing the web server setup, Amazon EFS integration, and automated log archival configuration.

This AMI serves as the base image for launching identical web server instances through the Auto Scaling Group.

**Reference:** `images/compute/4. AMI.png`


### 6.2 Create the Launch Template

Created a Launch Template named **`cafe-LT`** using the **`cafe-AMI-with-s3`** image.

The Launch Template includes the instance configuration required for Auto Scaling, including the AMI, instance type, IAM role, Security Group, key pair.
This ensures that every instance launched by the Auto Scaling Group is provisioned with a consistent configuration.

**References:**
- `images/compute/5. launch-template.png`
- `images/compute/6. LT-s3-role.png`

---
## Step 7: Configure Traffic Distribution

### 7.1 Create the Target Group

Created an Application Load Balancer Target Group named **`cafe-TG`** to route incoming HTTP requests to the EC2 instances.

The Target Group was configured to use HTTP on port **80** and health checks were enabled to monitor the availability of registered instances.

**Reference:** `images/compute/7. target-group.png`


### 7.2 Create the Application Load Balancer

Created an internet-facing Application Load Balancer named **`cafe-ALB`** across the two public subnets.

Configured a listener on **HTTP (Port 80)** and associated it with the **`cafe-TG`** Target Group to distribute incoming traffic across healthy EC2 instances.

The Application Load Balancer serves as the single entry point for users accessing the web application.
The Application Load Balancer DNS name can be used to access the deployed web application once healthy EC2 instances are registered with the Target Group.

**Reference:**
- `images/compute/9. app-load-balancer.png`
- `images/compute/10. app-load-balancer.png`

---
## Step 8: Configure Auto Scaling

### 8.1 Create the Auto Scaling Group

Created an Auto Scaling Group named **`cafe-ASG`** using the **`cafe-LT`** Launch Template.

Configured the Auto Scaling Group to launch instances across **`cafe-priv-subnet-1`** and **`cafe-priv-subnet-2`** to provide high availability across two Availability Zones.

Associated the Auto Scaling Group with the **`cafe-TG`** Target Group so that newly launched instances are automatically registered with the Application Load Balancer.

**Reference:** `images/compute/11. asg.png`


### 8.2 Configure Scaling Policy

Configured the Auto Scaling Group with a **desired capacity of 2**, a **minimum capacity of 1**, and a **maximum capacity of 4** instances.

Added a target tracking scaling policy based on **Average CPU Utilization** to automatically launch additional instances during increased load and terminate excess instances when demand decreases.

**Reference:** `images/compute/11. asg.png`


### 8.3 Verify Instance Registration

Verified that EC2 instances launched by the Auto Scaling Group were automatically registered with the **`cafe-TG`** Target Group and reported a healthy status before receiving traffic from the Application Load Balancer.

**Reference:** `images/validation/7. target-group.png`

---
# Step 9: Validation

### 9.1 Verify Website Accessibility

Verified that the web application was accessible through the **Application Load Balancer DNS**. The Application Load Balancer successfully routed incoming requests to healthy EC2 instances registered with the Target Group.

**Reference:** `images/validation/1. website-from-alb-dns.png`


### 9.2 Verify Auto Scaling

Verified that the Auto Scaling Group maintained the desired capacity and automatically launched additional EC2 instances in response to increased CPU utilization.

The Auto Scaling Group successfully scaled from **2 to 3** instances and later to the configured maximum capacity of **4** instances.

**References:**
- `images/validation/2. desired-capacity.png`
- `images/validation/3. scale-out.png`
- `images/validation/4. at-max-capacity.png`


### 9.3 Verify Automated Log Archival

Verified that the Apache **access** and **error** logs were successfully uploaded to the configured Amazon S3 bucket by the scheduled cron job.

**References:**
- `images/logging/4. logs-s3.png`
- `images/logging/5. logs-s3.png`

### 9.4 Verify Amazon EFS Mount

Verified that the Amazon EFS file system was successfully mounted on the EC2 instance at **`/var/www/html/img`**, ensuring shared storage was available for the web application.

**Reference:**
- `images/storage/4. EFS-mount-info.PNG`
