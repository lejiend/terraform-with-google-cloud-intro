# terraform-with-google-cloud-intro

A beginner-friendly introduction to **Terraform** on **Google Cloud Platform (GCP)**. This tutorial provisions a single Ubuntu virtual machine that installs and runs **Nginx** on boot, plus a firewall rule so you can reach it over HTTP and SSH.

## What gets created

| Resource | Name | Details |
| --- | --- | --- |
| `google_compute_instance` | `my-automation-instance` | `e2-small`, Ubuntu 24.04 LTS, zone `asia-southeast1-a`, ephemeral public IP |
| `google_compute_firewall` | `allow-http-ssh` | Allows TCP `22` (SSH) and `80` (HTTP) from `0.0.0.0/0` to instances tagged `application-server` |

The VM runs a startup script that installs Nginx, so once it boots you can open its public IP in a browser and see the Nginx welcome page.

## Project structure

```
.
├── providers.tf        # Terraform version, Google provider, project/region/zone
├── virtual-machine.tf  # VM instance, firewall rule, and public IP output
└── .gitignore          # Ignores state, .terraform/, tfvars, plan files
```

## Prerequisites

- A Google Cloud project with **billing enabled**
- The **Compute Engine API** enabled on that project
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.0`
- [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- An SSH key pair (e.g. `ssh-keygen -t ed25519`) if you want to SSH into the VM

## Setup

1. **Authenticate with Google Cloud**

   ```bash
   gcloud auth application-default login
   ```

2. **Enable the Compute Engine API** (if not already enabled)

   ```bash
   gcloud services enable compute.googleapis.com --project <your-project-id>
   ```

3. **Point the config at your project.** In `providers.tf`, replace `my-free-learning-tutorial` with your own project ID. Change `region`/`zone` too if you prefer somewhere other than Singapore (`asia-southeast1`) — remember to update the `zone` in `virtual-machine.tf` as well.

4. **Use your own SSH key.** In `virtual-machine.tf`, replace the `ssh-keys` metadata value with `<your-username>:<contents of your public key>`, e.g.:

   ```
   "ssh-keys" = "alice:ssh-ed25519 AAAA... alice@laptop"
   ```

## Usage

```bash
terraform init      # download the Google provider
terraform fmt       # (optional) format the .tf files
terraform validate  # check the configuration is valid
terraform plan      # preview what will be created
terraform apply     # create the resources (type "yes" to confirm)
```

When `apply` finishes, Terraform prints the VM's public IP:

```
Outputs:

instance_public_ip = "34.xxx.xxx.xxx"
```

### Verify it works

- **Web:** open `http://<instance_public_ip>` in a browser (give the startup script a minute or two to install Nginx).
- **SSH:**

  ```bash
  ssh <your-username>@<instance_public_ip>
  ```

You can print the IP again at any time with `terraform output instance_public_ip`.

## Clean up

To avoid ongoing charges, destroy everything when you're done:

```bash
terraform destroy
```

## Notes

- **Costs:** an `e2-small` VM is not covered by the GCP free tier, so it will incur a small hourly charge while running.
- **Security:** the firewall rule opens SSH and HTTP to the whole internet (`0.0.0.0/0`). That's fine for a short-lived tutorial, but for anything longer-lived, restrict `source_ranges` to your own IP.
- **State:** Terraform state is stored locally in `terraform.tfstate` and is git-ignored. For team use, consider a [GCS remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).
