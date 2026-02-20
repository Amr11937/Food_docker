# 🍅 Tomato: A Food Delivery App

Tomato is a full-featured, responsive food delivery application built using the **MERN stack** (MongoDB, Express, React, Node.js) with **Stripe** payment integration, fully **Dockerized**, deployed on **AWS** using **Terraform** for infrastructure provisioning, and automated end-to-end with a **Jenkins CI/CD pipeline**.

> **From code push to production in minutes!**
>
> `git push → GitHub Webhook → Jenkins builds & pushes Docker images → SSH deploys to AWS → App live ⚡`

---

## 🚀 Features

### Customer Interface (Frontend)

- **Responsive Design:** Developed with React, Tomato offers a fully responsive interface that adapts to various devices, from desktops to mobile screens, ensuring an optimized user experience.
- **User Authentication:** Secure user login and registration using JSON Web Tokens (JWT) to manage sessions and protect user data.
- **Browse and Search:** Users can browse restaurants, view menus, and search for food items by category, popularity, or dietary preference.
- **Order Management:** Customers can place orders, select their preferred delivery address, and track the status of their orders in real-time.
- **Payment Integration:** With Stripe integrated, users can make secure, hassle-free payments directly within the app.

### Admin Panel

- **User Management:** Admins can view and manage user accounts, including customer and delivery personnel information.
- **Menu and Restaurant Management:** Easily add, edit, and delete food items, categories, and restaurant details to keep the offerings up to date.
- **Order Tracking:** Real-time monitoring of active and past orders, with controls to update the order status (e.g., received, in-progress, completed, delivered).
- **Analytics:** Track key metrics like popular items, order frequency, and user activity to make informed decisions and improve services.

### Backend (Server)

- **API Development:** Built with Express, the backend provides RESTful APIs to handle requests, manage authentication, and connect the frontend and admin panel to the MongoDB database.
- **Data Storage:** MongoDB is used for storing user profiles, order details, restaurant data, and menu items in a scalable and efficient manner.
- **Real-Time Updates:** With WebSockets, users receive live updates on their order status from the moment they place it until delivery.
- **Security:** Data protection and secure endpoints, with encrypted user information and secure payment processing via Stripe.

---

## 🛠️ Technology Stack

| Layer                | Technologies                                     |
| -------------------- | ------------------------------------------------ |
| **Frontend**         | React, CSS3, Bootstrap/Material UI, Stripe.js    |
| **Backend**          | Node.js, Express.js, WebSockets                  |
| **Database**         | MongoDB                                          |
| **Payment**          | Stripe                                           |
| **Containerization** | Docker, Docker Compose                           |
| **IaC**              | Terraform                                        |
| **CI/CD**            | Jenkins (GitHub Webhooks)                        |
| **Cloud**            | AWS (VPC, EC2, Elastic IP, IAM, Security Groups) |

---

## 🏗️ Infrastructure — Terraform on AWS

The entire cloud infrastructure is provisioned as code using **Terraform**, deployable with a single command: `terraform apply`.

### What Terraform Provisions

| Resource                 | Description                                                          |
| ------------------------ | -------------------------------------------------------------------- |
| **Custom VPC**           | Isolated network with public subnets across **2 Availability Zones** |
| **EC2 — Jenkins Server** | Hosts the Jenkins CI/CD pipeline (with swap space for t3.micro)      |
| **EC2 — App Server**     | Runs the Dockerized application stack via Docker Compose             |
| **Elastic IPs**          | Static public IPs assigned to both EC2 instances                     |
| **Security Groups**      | Firewall rules for SSH, HTTP, HTTPS, and app-specific ports          |
| **IAM Roles & Policies** | Least-privilege access for EC2 instances and services                |

### Terraform Commands

```bash
cd terraform

# Initialize providers & modules
terraform init

# Preview infrastructure changes
terraform plan

# Provision the entire infrastructure
terraform apply

# Tear down all resources
terraform destroy
```

### Terraform Structure

```
terraform/
├── main.tf                  # Provider config, VPC, subnets, EC2 instances
├── variables.tf             # Input variables (region, instance type, key pair, etc.)
├── outputs.tf               # Output values (public IPs, DNS, instance IDs)
├── terraform.tfvars         # Variable values (git-ignored)
├── userdata/
│   ├── jenkins-server.sh    # User data script for Jenkins EC2 setup
│   └── app-server.sh        # User data script for App Server EC2 setup
└── modules/
    ├── vpc/                 # VPC, subnets, internet gateway, route tables
    ├── security-groups/     # Inbound/outbound rules
    ├── ec2/                 # EC2 instance definitions & Elastic IPs
    └── iam/                 # IAM roles & instance profiles
```

---

## 🔄 CI/CD Pipeline — Jenkins

Tomato uses a fully automated **Jenkins CI/CD pipeline** triggered on every GitHub push via **Webhooks**.

### Pipeline Workflow

```
git push → GitHub Webhook → Jenkins Pipeline Triggered
    ↓
Build 3 Docker Images (Frontend, Admin, Backend)
    ↓
Push to Docker Hub (tagged with build number)
    ↓
SSH into App Server → Pull latest images → Docker Compose Up
    ↓
🚀 App Live in Production
```

### Pipeline Stages

| Stage          | Description                                                        |
| -------------- | ------------------------------------------------------------------ |
| **Trigger**    | GitHub Webhook fires on push to `main` branch                      |
| **Checkout**   | Jenkins pulls the latest code from GitHub                          |
| **Build**      | Builds 3 Docker images — `client`, `admin`, `server`               |
| **Tag & Push** | Tags images with Jenkins build number and pushes to **Docker Hub** |
| **Deploy**     | SSH into App Server, pulls new images, runs `docker-compose up -d` |

### Key CI/CD Highlights

- **Auto-Triggered:** Every `git push` to GitHub automatically starts the pipeline — no manual intervention.
- **Build-Number Tagging:** Docker images are tagged with Jenkins build numbers for version tracking and easy rollbacks.
- **SSH Deployment:** Jenkins securely connects to the App Server via SSH to deploy the latest containers.
- **Secret Management:** Docker Hub credentials, SSH keys, and environment variables are managed via Jenkins Credentials store.

---

## 🧩 Key Challenges Solved

| Challenge                                 | Solution                                                                          |
| ----------------------------------------- | --------------------------------------------------------------------------------- |
| **t3.micro memory limits**                | Configured swap space on EC2 instances to handle Jenkins and Docker builds        |
| **Circular dependencies in Terraform**    | Refactored resource references and used `depends_on` to resolve dependency chains |
| **tmpfs disk space issues for Jenkins**   | Mounted persistent EBS volumes and adjusted Docker storage drivers                |
| **YAML heredoc indentation in user_data** | Used `templatefile()` function and external shell scripts for clean user data     |

---

## 📦 Getting Started

### Prerequisites

- [AWS Account](https://aws.amazon.com/) with programmatic access configured
- [Terraform](https://developer.hashicorp.com/terraform/install) (v1.5+)
- [Docker](https://www.docker.com/get-started) & [Docker Compose](https://docs.docker.com/compose/install/)
- [Jenkins](https://www.jenkins.io/) (provisioned automatically via Terraform)
- A [Stripe](https://stripe.com/) account for payment keys
- A [Docker Hub](https://hub.docker.com/) account for image storage

### 1. Clone the Repository

```bash
git clone https://github.com/ismai/Food_docker.git
cd Food_docker
```

### 2. Provision AWS Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This creates the VPC, 2 EC2 instances (Jenkins + App Server), Elastic IPs, Security Groups, and IAM Roles.

### 3. Configure Jenkins

1. Access Jenkins at `http://<jenkins-elastic-ip>:8080`
2. Install required plugins: Docker Pipeline, SSH Agent, GitHub Integration
3. Add credentials: Docker Hub, SSH key for App Server, GitHub Webhook secret
4. Create a pipeline pointing to the repository's `Jenkinsfile`
5. Set up GitHub Webhook to trigger on push events

### 4. Set Up Environment Variables

Create a `.env` file on the App Server:

```env
# MongoDB
MONGO_URI=mongodb://mongo:27017/tomato

# JWT
JWT_SECRET=your_jwt_secret

# Stripe
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key

# Server
PORT=4000
```

### 5. Deploy (Automatic)

Simply push code to GitHub:

```bash
git add .
git commit -m "New feature"
git push origin main
```

Jenkins will automatically build, push, and deploy the application to AWS. 🚀

### 6. Run Locally with Docker (Development)

```bash
docker-compose up --build
```

| Service     | URL                       |
| ----------- | ------------------------- |
| Frontend    | http://localhost:5173     |
| Admin Panel | http://localhost:5174     |
| Backend API | http://localhost:4000     |
| MongoDB     | mongodb://localhost:27017 |

### 7. Run Without Docker (Manual)

```bash
# Backend
cd server && npm install && npm start

# Frontend
cd ../client && npm install && npm start

# Admin Panel
cd ../admin && npm install && npm start
```

---

## 📁 Project Structure

```bash
Food_docker/
│
├── client/                          # Frontend (React)
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── utils/
│   └── Dockerfile
│
├── server/                          # Backend (Node.js, Express)
│   ├── config/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   └── Dockerfile
│
├── admin/                           # Admin Panel (React)
│   ├── components/
│   ├── pages/
│   └── Dockerfile
│
├── terraform/                       # Infrastructure as Code (AWS)
│   ├── main.tf                      # Provider, VPC, subnets, EC2 instances
│   ├── variables.tf                 # Input variable definitions
│   ├── outputs.tf                   # Output values (IPs, DNS)
│   ├── terraform.tfvars             # Variable values (git-ignored)
│   ├── userdata/
│   │   ├── jenkins-server.sh        # Jenkins EC2 bootstrap script
│   │   └── app-server.sh            # App Server EC2 bootstrap script
│   └── modules/
│       ├── vpc/                     # VPC, subnets, IGW, route tables
│       ├── security-groups/         # Firewall rules
│       ├── ec2/                     # EC2 instances & Elastic IPs
│       └── iam/                     # IAM roles & policies
│
├── Jenkinsfile                      # CI/CD pipeline definition
├── docker-compose.yml               # Docker Compose orchestration
├── .env                             # Environment variables (git-ignored)
├── .gitignore
├── README.md
└── package.json
```

---

## 🏛️ Architecture Diagram

```
                    ┌──────────────┐
                    │   Developer  │
                    └──────┬───────┘
                           │ git push
                           ▼
                    ┌──────────────┐
                    │    GitHub    │
                    └──────┬───────┘
                           │ Webhook
                           ▼
              ┌─────────────────────────┐
              │   Jenkins Server (EC2)  │
              │  ┌───────────────────┐  │
              │  │ Build Docker imgs │  │
              │  │ Push to Docker Hub│  │
              │  │ SSH Deploy ──────────────┐
              │  └───────────────────┘  │   │
              └─────────────────────────┘   │
                                            ▼
              ┌─────────────────────────────────────┐
              │         App Server (EC2)             │
              │  ┌─────────┐ ┌───────┐ ┌─────────┐  │
              │  │ Client  │ │ Admin │ │ Backend │  │
              │  │ :5173   │ │ :5174 │ │ :4000   │  │
              │  └─────────┘ └───────┘ └────┬────┘  │
              │                             │       │
              │                      ┌──────┴─────┐ │
              │                      │  MongoDB   │ │
              │                      │  :27017    │ │
              │                      └────────────┘ │
              └─────────────────────────────────────┘
                        AWS VPC (2 AZs)
```

---

## 🔮 Future Enhancements

- **Push Notifications:** Notify users about order updates and special offers.
- **Advanced Analytics:** Provide deeper insights for restaurant and admin users.
- **Multi-Language Support:** Make the app accessible to a broader audience by adding multiple languages.
- **Kubernetes Deployment:** Scale the application using EKS orchestration.
- **Monitoring & Logging:** Integrate Prometheus, Grafana, and CloudWatch for observability.
- **Blue/Green Deployments:** Zero-downtime deployments with traffic switching.

---

## 🤝 Contribution Guidelines

1. Fork this repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m "Add your feature"`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

Please follow standard coding practices and add meaningful comments to your code.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**#Terraform #AWS #Jenkins #Docker #React #NodeJS #MongoDB #DevOps #CICD**

Enjoy exploring the code and features of Tomato! Feel free to reach out for any questions or suggestions. 🍕
