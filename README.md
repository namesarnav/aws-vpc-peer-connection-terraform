
![VPC-A](https://github.com/user-attachments/assets/8105a75e-7462-408f-a0f5-7905248b27c1)

# AWS VPC Peering Connection with Bastion Host

This Terraform project automates the creation of two Virtual Private Clouds (VPCs) and establishes a VPC Peering Connection between them. The project also provisions a bastion host in a public subnet, which allows secure SSH access to private instances in both VPCs. This architecture ensures efficient, secure communication between VPC resources while adhering to best practices for cloud networking and security.

## Architecture Overview

- **VPC 1** and **VPC 2** with private subnets.
- **VPC Peering Connection** between VPC 1 and VPC 2.
- **Bastion Host** in a public subnet within VPC 1, allowing SSH access to private instances.
- Security groups to control access to the instances and bastion host.

## Prerequisites

Ensure you have the following installed locally:

- [Terraform](https://www.terraform.io/downloads.html)
- AWS CLI configured with the appropriate access credentials
- SSH key pair for accessing the bastion host

## Project Structure

```
.
├── main.tf               # Main Terraform configuration
├── variables.tf          # Variables for VPCs, instances, etc.
├── provider.tf           # AWS provider configuration
├── terraform.tfvars      # Variable values (keys, instance types, etc.)
├── outputs.tf            # Outputs (IP addresses, etc.)
└── README.md             # This file
```

## Instructions to Run Locally

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/namesarnav/VPC-Peering-using-terraform.git
   cd VPC-Peering-using-terraform.git
   ```

2. **Update Variables**:
   Modify `terraform.tfvars` to set your custom values like VPC CIDR blocks, key pair name, and instance types.

3. **Initialize Terraform**:
   Initialize the Terraform environment by downloading the necessary provider plugins.
   ```bash
   terraform init
   ```

4. **Plan the Infrastructure**:
   Run the following command to see the execution plan and ensure everything looks correct.
   ```bash
   terraform plan
   ```

5. **Apply the Infrastructure**:
   Create the infrastructure by applying the Terraform configuration.
   ```bash
   terraform apply
   ```
   Once completed, Terraform will output the bastion host's public IP and private instance IPs.

6. **Access Instances via Bastion Host**:
   Use the bastion host to SSH into private instances across both VPCs. Example command:
   ```bash
   ssh -i path-to-your-key.pem ec2-user@<bastion-host-ip>
   ```

## **Warning: Remember to Destroy Resources When Done!**

When you're finished with the project, **destroy the infrastructure** to avoid unnecessary AWS charges:
```bash
terraform destroy
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
