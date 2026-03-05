# Buildr — CI/CD Pipeline for FastAPI ONNX Inference API

This project demonstrates a **production-style CI/CD pipeline** for deploying a containerized machine learning inference API.

The pipeline automates **code validation, container image builds, and deployment** using **GitHub Actions, Docker, and AWS EC2**, while infrastructure is provisioned using **Terraform**.

The API itself (FastAPI + ONNX Runtime) serves as a **sample workload**. The primary focus of the project is showcasing a **fully automated CI/CD workflow from commit to deployment**, with reproducible infrastructure and reliable delivery.

---

# Architecture

```
Developer
   │
   ▼
GitHub Repository
   │
   ▼
GitHub Actions Pipeline
   ├── Lint (Ruff, Black)
   ├── Unit Tests (Pytest)
   ├── Build Docker Image
   └── Tag Image with Git SHA
   │
   ▼
Container Registry
   │
   ▼
AWS EC2 Instance
   │
   ▼
FastAPI ONNX Inference API
```

Infrastructure for the EC2 instance and networking is provisioned using **Terraform**, with remote state stored in **Amazon S3** to ensure reproducible environments.

---

# Tech Stack

### Application

FastAPI, ONNX Runtime

### CI/CD

GitHub Actions

### Containerization

Docker

### Infrastructure

AWS EC2, Terraform, Amazon S3 (remote state)

### Testing & Code Quality

Pytest, Ruff, Black

---

# Repository Structure

```
.
├── app/            FastAPI application
├── tests/          Unit tests
├── infra/          Terraform infrastructure
├── scripts/        Deployment scripts
├── model.onnx
├── Dockerfile
└── README.md
```

---

# CI/CD Pipeline Overview

The core feature of this project is the automated **CI/CD pipeline**.

### Continuous Integration

Every push triggers GitHub Actions to run:

* **Linting** using Ruff and Black
* **Unit tests** using Pytest

This ensures code quality and prevents broken code from reaching production.

### Continuous Deployment

When changes are pushed or merged into the `main` branch, the pipeline automatically:

1. Builds a Docker image
2. Tags the image using the **Git commit SHA**
3. Pushes the image to the container registry
4. Deploys the updated container to the **AWS EC2 instance**

This guarantees that **only verified code is deployed** and that deployments remain **traceable and reproducible**.

---

# Infrastructure & Deployment

Infrastructure is provisioned using **Terraform**, enabling fully reproducible cloud environments.

Resources provisioned include:

* AWS EC2 instance
* VPC and networking configuration
* Security groups
* S3 bucket for Terraform remote state

After the infrastructure is created, all subsequent deployments are handled automatically by the **CI/CD pipeline**.

---

# Deployment Workflow

The deployment process follows a fully automated flow:

1. Developer pushes code to GitHub
2. GitHub Actions runs **linting and unit tests**
3. On merges to `main`:

   * Docker image is built
   * Image is tagged using the Git commit SHA
   * Image is pushed to the container registry
4. The EC2 instance pulls the new image and updates the running container

This workflow demonstrates **end-to-end CI/CD automation from commit to production deployment**.

---

# DevOps Concepts Demonstrated

This project highlights several important DevOps practices:

* Continuous Integration with automated testing and linting
* Continuous Deployment triggered by `main` branch updates
* Containerized application deployment using Docker
* Immutable deployments with Git SHA–tagged images
* Infrastructure as Code using Terraform
* Reproducible cloud environments with Terraform remote state
* Automated container deployment to AWS EC2

---

# Local Development (Optional)

Clone the repository:

```
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>
```

Create a virtual environment and install dependencies:

```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Run the API locally:

```
uvicorn app.app:app --reload
```

---

# Running with Docker

Build the Docker image:

```
docker build -t buildr .
```

Run the container:

```
docker run -p 8000:8000 buildr
```

Once running, the API will be available at:

```
http://localhost:8000
```

Interactive API documentation:

```
http://localhost:8000/docs
```

---

# What This Project Demonstrates

* End-to-end CI/CD pipeline implementation
* Automated container image builds
* Cloud deployment automation
* Infrastructure as Code with Terraform
* Reliable and reproducible application delivery

---
