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

**Reference:**
- `images/storage/1. EFS.png`

- 
### 3.2 Create an EFS Access Point

Created an EFS Access Point to provide a consistent mount path and simplify access to the shared file system from EC2 instances.

**Reference:**
- `images/storage/2. access-point.png`


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

