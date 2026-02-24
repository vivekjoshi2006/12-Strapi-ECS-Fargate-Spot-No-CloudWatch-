## 🚀 Project Overview

This project demonstrates deploying a **Strapi application** on **Amazon ECS (Fargate Spot)** using **Terraform Infrastructure as Code (IaC)**.

The goal is to provision a production-style containerized deployment using AWS managed services.

---

## 🏗️ Architecture Components

* **AWS ECS Cluster (Fargate Spot)**
* **ECS Task Definition**
* **ECS Service**
* **Default VPC & Subnets**
* **Security Group (Port 1337 exposed)**
* **ECR Image (Strapi container)**

---

## ⚙️ Infrastructure Provisioning

Infrastructure was provisioned using:

```bash
terraform init
terraform apply -auto-approve
```

Terraform successfully created:

* ECS Cluster
* Capacity Provider Strategy (FARGATE_SPOT)
* Task Definition
* ECS Service
* Security Group
* Networking resources

---

## 📊 Deployment Status

The ECS Service was successfully created with:

* desiredCount = 1
* runningCount = 0

Task execution failed due to IAM role assumption restrictions:

```
ECS was unable to assume the role ecsTaskExecutionRole.
```

This is caused by **IAM PassRole permission limitations** in the AWS account used for deployment.

Infrastructure provisioning completed successfully. ✅

---

## 🎓 Key Learning Outcomes

* ECS Fargate deployment using Terraform
* Capacity provider strategy configuration
* IAM role dependency in ECS task execution
* Debugging ECS service events


