# Self-Managed TemporalIO Infrastructure

This repository provides Terraform modules for deploying a self-hosted TemporalIO cluster on Kubernetes with PostgreSQL as the database backend. It includes automated deployment through Terraform and Helm charts, with a complete CI/CD pipeline for releases.

## Overview

TemporalIO is a distributed orchestration engine for executing workflows as code. This infrastructure setup deploys:

- **TemporalIO Server**: Core Temporal services (frontend, history, matching, worker)
- **PostgreSQL Database**: Primary data store for Temporal workflows and visibility data
- **Kubernetes Resources**: Namespaces, services, deployments, and persistent storage
- **Automated Namespace Setup**: Initial Temporal namespace registration

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Temporal UI   │    │ Temporal Client  │    │ Worker Apps     │
│                 │    │                  │    │                 │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
┌────────────────────────────────┼──────────────────────────────────┐
│                    Kubernetes Cluster                             │
│                                                                   │
│  ┌─────────────────┐  ┌───────────────────────────────────────┐   │
│  │ Temporal Helm   │  │ PostgreSQL Database                   │   │
│  │ Chart           │  │ (temporal + visibility databases)     │   │
│  │                 │  │                                       │   │
│  │ • Frontend      │  │ • Deployment (PostgreSQL 16)          │   │
│  │ • History       │  │ • Service (ClusterIP)                 │   │
│  │ • Matching      │  │ • Persistent Volume Claim             │   │
│  │ • Worker        │  │ • Secrets & ConfigMaps                │   │
│  └─────────────────┘  └───────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- **Kubernetes Cluster** (v1.20+)
- **Terraform** (v1.0+)
- **Helm** (v3.0+)
- **kubectl** configured with cluster access
- **Storage Class** named `standard` (or configure via variables)

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd self-managed-temporalio
   ```

2. **Initialize Terraform:**
   ```bash
   cd infrastructure
   terraform init
   ```

3. **Plan and deploy:**
   ```bash
   terraform plan
   terraform apply
   ```

4. **Verify deployment:**
   ```bash
   kubectl get pods -n temporal
   kubectl get services -n temporal
   ```

## Configuration

### Key Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `namespace` | `temporal` | Kubernetes namespace for Temporal |
| `temporal_chart_version` | `1.0.0-rc.1` | Helm chart version for Temporal |
| `temporal_db_name` | `temporal` | Main database name |
| `temporal_visibility_db_name` | `visibility` | Visibility database name |
| `temporal_db_user` | `temporal` | Database username |
| `temporal_db_password` | `temporal1234` | Database password |
| `storage_class_name` | `standard` | Kubernetes storage class |

### Customizing Variables

Create a `terraform.tfvars` file or use environment variables:

```hcl
# terraform.tfvars
namespace = "temporal-prod"
temporal_db_password = "your-secure-password"
storage_class_name = "fast-ssd"
```

## Components

### Database Module (`infrastructure/database/`)

- **PostgreSQL 16** deployment with health checks
- **Persistent Storage** via PVC
- **Database Initialization** with setup scripts
- **Kubernetes Secrets** for credentials
- **Service** for cluster access

### Main Infrastructure (`infrastructure/`)

- **Kubernetes Namespace** creation
- **Helm Release** for Temporal chart
- **Values Template** generation with dynamic database configuration
- **Namespace Registration** job for initial Temporal setup

### CI/CD Pipeline (`.github/workflows/`)

- **Automated Releases** on tag push
- **Package Creation** with Terraform modules
- **GitHub Releases** with compiled assets

## Accessing Temporal

Once deployed, you can access Temporal through:

- **Web UI:** Port-forward the frontend service
  ```bash
  kubectl port-forward -n temporal svc/temporal-frontend 7233:7233
  ```
  Then access `http://localhost:7233`

- **tctl CLI:** Use the admin-tools container
  ```bash
  kubectl exec -n temporal -it deployment/temporal-frontend -- tctl --namespace default
  ```

## Database Schema

The deployment creates two PostgreSQL databases:

1. **`temporal`**: Stores workflow execution data, history, and state
2. **`visibility`**: Stores visibility data for querying and monitoring

## Maintenance

### Upgrading Temporal

1. Update `temporal_chart_version` in `variables.tf`
2. Run `terraform apply`
3. Monitor the upgrade progress

### Database Backup

Implement regular backups of the PostgreSQL PVC using your preferred backup solution.

### Scaling

The configuration supports horizontal scaling of Temporal components. Adjust replica counts in the Helm values as needed.

## Security Considerations

- Database passwords are stored as Kubernetes secrets
- Default credentials are provided for development - change for production
- Network policies should be implemented for production environments
- Consider using external managed databases for production workloads

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Check PostgreSQL pod logs: `kubectl logs -n temporal -l app=temporal-db-deployment`
   - Verify secrets are correctly created

2. **Temporal Namespace Registration**
   - Check namespace setup job: `kubectl describe job -n temporal temporal-namespace-setup`
   - Verify frontend service is accessible

3. **Persistent Volume Issues**
   - Check PVC status: `kubectl get pvc -n temporal`
   - Verify storage class availability

## Development

### Local Development

1. Make changes to Terraform files
2. Run `terraform validate` and `terraform plan`
3. Test in a development environment

### Releases

1. Create a new tag: `git tag v1.0.0 && git push origin v1.0.0`
2. GitHub Actions will automatically create a release with packaged assets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues related to:
- **TemporalIO**: Visit [Temporal.io documentation](https://docs.temporal.io/)
- **This Infrastructure**: Open a GitHub issue in this repository
