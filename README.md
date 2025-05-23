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

Let me know if you’d like to tailor this explanation for your resume or an interview script.
