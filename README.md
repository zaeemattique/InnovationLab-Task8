# ECS Fargate Node.js Deployment with ALB, EFS & CodePipeline

A comprehensive guide for deploying a highly available Node.js application on AWS ECS with automated CI/CD using CodePipeline.

##  Project Overview

This project demonstrates a production-ready architecture for deploying containerized Node.js applications on AWS ECS (Elastic Container Service) with:

- **High Availability**: Multi-AZ deployment across `us-west-2a` and `us-west-2b`
- **Load Balancing**: Internet-facing Application Load Balancer (ALB)
- **Persistent Storage**: Amazon EFS for shared data across containers
- **Auto Scaling**: EC2-based Auto Scaling Group for ECS tasks
- **CI/CD Pipeline**: Automated deployment via AWS CodePipeline
- **Containerization**: Docker containers stored in Amazon ECR

##  Architecture

The infrastructure consists of:

- **VPC** with public and private subnets across 2 availability zones
- **NAT Gateways** for private subnet internet access
- **Application Load Balancer** distributing traffic to ECS tasks
- **ECS Cluster** running on self-managed EC2 instances
- **EFS File System** with mount points in each AZ
- **CodePipeline** automating build and deployment from GitHub

  ![alt](https://raw.githubusercontent.com/zaeemattique/InnovationLab-Task7/refs/heads/main/Task7%20Architecture.drawio.png)

##  Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with Node.js application
- Docker installed locally
- AWS CLI configured

### Deployment Steps

#### 1. Network Infrastructure

Create a VPC with the following configuration:

- **VPC CIDR**: `10.0.0.0/16`
- **Subnets**:
  - Public Subnet A: `10.0.1.0/24` (us-west-2a)
  - Private Subnet A: `10.0.2.0/24` (us-west-2a)
  - Public Subnet B: `10.0.3.0/24` (us-west-2b)
  - Private Subnet B: `10.0.4.0/24` (us-west-2b)
- **NAT Gateways**: One in each public subnet
- **Internet Gateway**: Attached to VPC
- **Route Tables**:
  - Public: Routes `0.0.0.0/0` to IGW
  - Private A: Routes `0.0.0.0/0` to NAT Gateway A
  - Private B: Routes `0.0.0.0/0` to NAT Gateway B

#### 2. EFS Configuration

Set up Amazon EFS for persistent storage:

```
File System Name: Task7-EFS-Zaeem
Encryption: Enabled
Access Point: Task7-EFS-AP-Zaeem
  - Root Directory: /
  - POSIX UID/GID: 1000
  - Owner UID/GID: 1000
  - Permissions: 0755
Mount Targets: Private subnets in both AZs
```

#### 3. Docker Image

Build and push your Docker image to ECR:

```bash
# Build the image
docker image -t nodejs:latest -f DockerFile.yaml .

# Tag for ECR
docker tag nodejs:latest <ecr-uri>/zaeem/task7:latest

# Push to ECR
docker push <ecr-uri>/zaeem/task7:latest
```

#### 4. ECS Cluster Setup

**Launch Template**:
- AMI: Amazon Linux 2023
- Instance Type: t3.micro
- Storage: 8 GiB EBS

**Application Load Balancer**:
- Scheme: Internet-facing
- Listener: HTTP on port 80
- Target Group: Forward traffic to ECS tasks

**Auto Scaling Group**:
- Desired Capacity: 2
- Min: 1, Max: 3
- Subnets: Private subnets in both AZs

**ECS Cluster**:
- Infrastructure: Fargate + Self-managed EC2
- Linked to Auto Scaling Group

**Task Definition**:
- vCPU: 1, Memory: 3 GB
- Container Port: 3000 → 80
- Network Mode: Bridge
- EFS Volume mounted for persistent storage

**ECS Service**:
- Desired Tasks: 2
- Compute: Capacity Provider Strategy
- Load Balancer: Integrated with ALB

#### 5. CI/CD Pipeline

Configure AWS CodePipeline with three stages:

**Source Stage**:
- Provider: GitHub (OAuth)
- Trigger: Automatic on code commits

**Build Stage**:
- Provider: AWS CodeBuild
- Environment Variables:
  ```
  REGION=us-west-2
  ACCOUNT_ID=504649076991
  REPO_NAME=zaeem/task7
  IMAGE_TAG=latest
  ```
- Buildspec: `buildspec.yml` in repository root

**Deploy Stage**:
- Provider: Amazon ECS
- Cluster: Task7-ECS-Cluster-Zaeem
- Service: Task7-NodeJS-Zaeem-Service
- Timeout: 15 minutes

#### 6. Testing & Verification

- Push commits to GitHub to trigger the pipeline
- Monitor task deployment in ECS console
- Access application via ALB DNS name

##  Important Considerations

### Key Challenges & Solutions

1. **Container Resource Allocation**
   - Ensure task definition resources are less than EC2 instance resources
   - Otherwise, tasks will remain in pending state

2. **Build Artifacts**
   - Specify artifacts output in `buildspec.yml`
   - Required for Deploy Stage to access build outputs
   - Prevents misleading S3 permission errors

3. **IAM Permissions**
   - Pipeline service role needs proper policies
   - Include permissions for CodeBuild, ECS, ECR, and S3

## 🛠️ Technologies Used

- **AWS ECS** (Elastic Container Service)
- **AWS Fargate** & EC2
- **Application Load Balancer** (ALB)
- **Amazon EFS** (Elastic File System)
- **Amazon ECR** (Elastic Container Registry)
- **AWS CodePipeline**
- **AWS CodeBuild**
- **Docker**
- **Node.js**

##  Resource Naming Convention

All resources follow the naming pattern: `Task7-<ResourceType>-Zaeem`

Examples:
- VPC: `Task7-VPC-Zaeem`
- ECS Cluster: `Task7-ECS-Cluster-Zaeem`
- Pipeline: `Task7-Pipeline-Zaeem`

##  License

This project is created as part of a Cloud Internship training program.

##  Author

**Zaeem Attique Ashar**  
Cloud Intern

---

For detailed step-by-step instructions, refer to the complete documentation.
