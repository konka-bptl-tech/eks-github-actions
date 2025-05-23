# eks-github-actions
Here’s a clear **question and answer** pair for your scenario, framed in a way suitable for interviews or documentation:

---

### ❓**Question:**

I created an Amazon EKS cluster using Terraform, and it automatically created a security group that only allows inbound traffic from itself. I launched a bastion EC2 instance in a public subnet of the same VPC and tried accessing the EKS cluster using `kubectl` from the bastion. However, the connection to the EKS API server fails with a timeout error.

Surprisingly, I’m able to access the same EKS cluster from my personal Windows machine using `kubectl`, even though the EKS security group doesn’t allow public access explicitly. Why does it work from my local machine but not from the bastion in the same network?

---

### ✅**Answer:**

This happens because of how **EKS endpoint access** is configured:

When an EKS cluster is created with **public endpoint access enabled**, the EKS control plane is accessible over the **internet**, and access is authenticated using IAM credentials—not security groups. That’s why your local Windows machine can access the EKS cluster API, even if its security group doesn't allow public traffic — because it goes through the **public endpoint** (`*.eks.amazonaws.com`).

However, when you access the EKS API from an EC2 bastion inside the VPC, AWS tries to route traffic through the **private endpoint** of the EKS cluster (if enabled). This means:

* Your **bastion uses the internal VPC route** to reach the EKS control plane.
* The **cluster’s SG must explicitly allow inbound TCP on port 443** from the bastion’s IP, subnet CIDR, or security group.
* Since the default EKS security group only allows traffic from itself, the bastion’s traffic is blocked — resulting in a **timeout**.

---

### 🔧 Solution:

To allow access from the bastion host, you have two options:

1. **Add a security group rule** to the EKS control plane SG:

   ```hcl
   Type: HTTPS
   Port: 443
   Source: <bastion's SG or subnet CIDR>
   ```

2. Alternatively, if using public access:

   * Ensure the **public endpoint is enabled**, and
   * Add the **VPC CIDR block** or **0.0.0.0/0 (for testing only)** to the **public access CIDR allow list**.

---

### ✅ Recommendation:

For production environments, it's best to use **private endpoint access** and:

* Add interface VPC endpoints for EKS API.
* Secure access using fine-grained **security group rules**.

---
Great thought, Konka! You're now moving from traditional `aws-auth` based access to **fine-grained RBAC with EKS Access Entry**, which is the **modern and recommended approach** (especially from EKS Pod Identity and multi-tenant access management perspective).

---

## 🎯 Goal Recap

You want to give:

* **Siva**: **Read-only access** to the **`expense` namespace**
* **Ram**: **Full access** to the **`instana` namespace**

And you want to achieve this using **EKS Access Entry** via **Terraform**.

---

## ✅ Step-by-step Plan (Terraform-based)

### 🔹 Step 1: Create IAM Users or use existing ones

Make sure `siva` and `ram` are AWS IAM users (or roles if using SSO/federation).

You’ll need their **IAM ARN**.

---

### 🔹 Step 2: Create `eks_access_entry` for each user

```hcl
resource "aws_eks_access_entry" "siva" {
  cluster_name = module.eks.cluster_name
  principal_arn = "arn:aws:iam::<account_id>:user/siva"
  type          = "STANDARD"
}

resource "aws_eks_access_entry" "ram" {
  cluster_name = module.eks.cluster_name
  principal_arn = "arn:aws:iam::<account_id>:user/ram"
  type          = "STANDARD"
}
```

---

### 🔹 Step 3: Create RBAC Roles and RoleBindings

You’ll define Kubernetes RBAC using Terraform (or Helm if you're templating).

#### 🧾 For Siva (Read-only in `expense`):

```hcl
resource "kubernetes_role" "siva_expense_readonly" {
  metadata {
    name      = "read-only"
    namespace = "expense"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "siva_binding" {
  metadata {
    name      = "siva-readonly-binding"
    namespace = "expense"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.siva_expense_readonly.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::<account_id>:user/siva"
    api_group = "rbac.authorization.k8s.io"
  }
}
```

---

#### 🧾 For Ram (Full access in `instana`):

```hcl
resource "kubernetes_role" "ram_instana_admin" {
  metadata {
    name      = "admin"
    namespace = "instana"
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions", "*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "ram_binding" {
  metadata {
    name      = "ram-admin-binding"
    namespace = "instana"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.ram_instana_admin.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::<account_id>:user/ram"
    api_group = "rbac.authorization.k8s.io"
  }
}
```

---

## ⚠️ Important Notes

* Make sure your EKS cluster has **Access Entry** support (EKS version >= 1.24).
* `aws_eks_access_entry` adds users without touching the `aws-auth` ConfigMap.
* These users must run `aws eks update-kubeconfig` to access the cluster.
* If you’re using SSO or federated identities, use their IAM Role ARN instead of User ARN.

---

Do you want this entire config in a single Terraform module? Or do you want help integrating it into your current setup?

