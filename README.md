# DevOps Network Lab V2 (AWS Academy Ready) - Pr Noureddine GRASSA

## Stack
- AWS EC2 (Terraform)
- Docker Compose
- Ansible
- GitHub Actions

## Architecture

- **PC1 & PC2** : Containers Alpine sur VLAN 10
- **PC3** : Container Alpine sur VLAN 20
- **Router** : Ubuntu avec IP forwarding et iptables

### Schéma logique réseau

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AWS EC2 — Ubuntu 24.04 (us-east-1)                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                          Docker Engine                                │  │
│  │                                                                       │  │
│  │  ┌──────────────────────────┐       ┌──────────────────────────────┐  │  │
│  │  │  VLAN 10 (bridge)        │       │  VLAN 20 (bridge)            │  │  │
│  │  │  192.168.10.0/24         │       │  192.168.20.0/24             │  │  │
│  │  │                          │       │                              │  │  │
│  │  │  ┌──────────────────┐    │       │  ┌──────────────────────┐   │  │  │
│  │  │  │  pc1 (Alpine)    │    │       │  │  pc3 (Alpine)        │   │  │  │
│  │  │  │  192.168.10.2    │    │       │  │  192.168.20.2        │   │  │  │
│  │  │  └──────────────────┘    │       │  └──────────────────────┘   │  │  │
│  │  │  ┌──────────────────┐    │       │                              │  │  │
│  │  │  │  pc2 (Alpine)    │    │       │  gw: 192.168.20.1 (eth1)    │  │  │
│  │  │  │  192.168.10.3    │    │       └──────────────┬───────────────┘  │  │
│  │  │  └──────────────────┘    │                      │                  │  │
│  │  │                          │       ┌──────────────┘                  │  │
│  │  │  gw: 192.168.10.1 (eth0) │       │                                 │  │
│  │  └──────────────┬───────────┘       │                                 │  │
│  │                 │                   │                                 │  │
│  │                 └────────┬──────────┘                                 │  │
│  │                          │                                            │  │
│  │              ┌───────────▼──────────────┐                             │  │
│  │              │  router (Ubuntu 24.04)   │                             │  │
│  │              │  privileged              │                             │  │
│  │              │  eth0: 192.168.10.1      │                             │  │
│  │              │  eth1: 192.168.20.1      │                             │  │
│  │              │  ip_forward = 1          │                             │  │
│  │              │  iptables FORWARD ACCEPT │                             │  │
│  │              │  MASQUERADE (NAT)        │                             │  │
│  │              └──────────────────────────┘                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│  Security Group: SSH :22 (0.0.0.0/0) — Terraform / t2.large / gp3 20GB     │
└─────────────────────────────────────────────────────────────────────────────┘

Flux inter-VLAN :
  pc1 (10.2) ──► router eth0 (10.1) ──► router eth1 (20.1) ──► pc3 (20.2)

Pipeline CI/CD :
  GitHub Actions ──► Terraform ──► EC2 ──► Docker Compose ──► Ansible ──► test.sh
```

| Conteneur | Image        | Réseau  | Adresse IP     | Rôle                    |
|-----------|--------------|---------|----------------|-------------------------|
| pc1       | alpine       | vlan10  | 192.168.10.2   | Poste client VLAN 10    |
| pc2       | alpine       | vlan10  | 192.168.10.3   | Poste client VLAN 10    |
| pc3       | alpine       | vlan20  | 192.168.20.2   | Poste client VLAN 20    |
| router    | ubuntu:24.04 | vlan10 + vlan20 | 192.168.10.1 / 192.168.20.1 | Routeur inter-VLAN |

## Secrets GitHub requis

Avant de pusher, configurez ces secrets dans les paramètres de votre repo GitHub :

- `AWS_ACCESS_KEY_ID` : Votre clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY` : Votre clé secrète AWS
- `AWS_SESSION_TOKEN` : Token de session AWS (requis pour AWS Academy)
- `AWS_DEFAULT_REGION` : Région AWS (us-east-1)
- `EC2_SSH_PRIVATE_KEY` : Votre clé SSH privée pour EC2 (format PEM)

## Usage

### Déploiement automatique
```bash
git push origin master
```
Le workflow GitHub Actions s'exécute automatiquement et :
1. Configure les credentials AWS
2. Initialise Terraform
3. Crée l'instance EC2
4. Déploie Docker Compose
5. Exécute le playbook Ansible
6. Lance les tests de connectivité

### Déploiement local (sans AWS)
```bash
docker compose up -d
ansible-playbook ansible/playbook.yml
bash scripts/test.sh
```

### Tests manuels
```bash
# Tester la connectivité intra-VLAN (PC1 → PC2)
docker exec pc1 ping -c 2 192.168.10.3

# Tester la connectivité inter-VLAN (PC1 → PC3 via router)
docker exec pc1 ping -c 2 192.168.20.2

# Vérifier l'IP forwarding
docker exec router sysctl net.ipv4.ip_forward

# Accéder à un container
docker exec -it pc1 sh

# Voir l'état des containers
docker compose ps
```

## Notes
- L'AMI `ami-0e86e20dae9224db8` est valide pour AWS Academy (us-east-1)
- La clé SSH `vockey` doit être disponible dans votre compte AWS
- Le secret `AWS_SESSION_TOKEN` est obligatoire avec AWS Academy (credentials temporaires)
