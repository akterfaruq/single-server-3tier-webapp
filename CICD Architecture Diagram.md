┌────────────────────────┐
│     Developer (Git)     │
│  Push Code to GitHub    │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│      GitHub Repo       │
│  (Frontend / Backend)  │
└───────────┬────────────┘
            │  Trigger
            ▼
┌────────────────────────┐
│   GitHub Actions CI    │
│------------------------│
│ 1. Checkout Code       │
│ 2. Install Dependencies│
│ 3. Run Tests           │
│ 4. Build Application   │
│ 5. Build Docker Image  │
│ 6. Push Image to Hub   │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│     Docker Registry    │
│      (Docker Hub)      │
└───────────┬────────────┘
            │ Pull Image
            ▼
┌────────────────────────┐
│   Kubernetes Cluster   │
│------------------------│
│  Deployments           │
│  Services              │
│  Ingress Controller    │
│  Secrets               │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│      End Users         │
│   Access via Ingress   │
└────────────────────────┘
