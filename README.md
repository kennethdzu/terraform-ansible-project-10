# Self-Monitoring Infrastructure with Prometheus, Grafana, & Ansible

## Project Overview
This project provisions a fully self-monitoring infrastructure cluster using **Infrastructure as Code (IaC)** principles. It demonstrates the implementation of a modern Observability Pipeline where infrastructure components (Web, DB, and Monitor nodes) automatically report metrics to a centralized dashboard.

The goal was to simulate a production-grade "Day 2 Operations" scenario where visibility and uptime monitoring are as critical as deployment.

## Architecture
The cluster consists of three Virtual Machines running on **AlmaLinux 9**, provisioned via KVM/Libvirt:

* **Monitor Node (192.168.110.10):**
    * **Prometheus:** Scrapes metrics from all nodes every 15s.
    * **Grafana:** Visualizes metrics via the "Node Exporter Full" dashboard.
    * Deployed as systemd-managed containers (**Podman Quadlets**).
* **Web Node (192.168.110.20):**
    * Hosts an Nginx Web Server (Quadlet).
    * Reports system metrics via **Node Exporter**.
* **DB Node (192.168.110.30):**
    * Hosts a Redis Database (Quadlet).
    * Reports system metrics via **Node Exporter**.

## Tech Stack
* **Infrastructure:** Terraform (Libvirt Provider), KVM/QEMU
* **Configuration Management:** Ansible (Roles, Jinja2 Templates, Galaxy Collections)
* **Container Runtime:** Podman (Rootless, Systemd integration via Quadlets)
* **Observability:** Prometheus, Grafana, Node Exporter
* **OS:** AlmaLinux 9 (RHEL Compatible)

## Project Structure
```text
.
├── ansible/
│   ├── group_vars/      # Global variables (e.g., node_exporter_version)
│   ├── roles/
│   │   ├── common/      # Installs Node Exporter binary & Systemd service
│   │   ├── monitor/     # Templates Prometheus config & Quadlets
│   │   ├── web/         # Deploys Nginx
│   │   └── db/          # Deploys Redis
│   ├── inventory.ini    # Static IP mapping
│   └── playbook.yml     # Master orchestration
├── terraform/
│   ├── main.tf          # Hardware definition (CPU Passthrough, Storage Pool)
│   └── ...
└── .github/workflows/   # CI Pipeline for IaC validation
```

## Automation Highlights
1.  **Dynamic Configuration:** The `prometheus.yml` configuration file is generated dynamically using Ansible Jinja2 loops. It automatically detects every host in the inventory and adds it as a scrape target.
2.  **Systemd Integration:** All containers are managed as native Systemd services (Quadlets), ensuring they start on boot and restart on failure.
3.  **Security:**
    * **Firewalld:** Strict rules applied; only necessary ports (9090, 3000, 9100) are opened.
    * **SELinux:** Enforcing mode is maintained. Container volumes are correctly labeled (`:Z`).

## Usage

### 1. Provision Infrastructure
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Configure Systems
```bash
cd ../ansible
ansible-galaxy install -r requirements.yml
ansible-playbook playbook.yml
```

### 3. Access Dashboards
* **Prometheus:** http://192.168.110.10:9090
* **Grafana:** http://192.168.110.10:3000 (Default: admin/admin)

## 📝 License
This project is open source and available under the MIT License.
