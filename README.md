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
│  │  │  172.19.0.0/16           │       │  172.18.0.0/16               │  │  │
│  │  │                          │       │                              │  │  │
│  │  │  ┌──────────────────┐    │       │  ┌──────────────────────┐   │  │  │
│  │  │  │  pc1 (Alpine)    │    │       │  │  pc3 (Alpine)        │   │  │  │
│  │  │  │  172.19.0.2      │    │       │  │  172.18.0.2          │   │  │  │
│  │  │  └──────────────────┘    │       │  └──────────────────────┘   │  │  │
│  │  │  ┌──────────────────┐    │       │                              │  │  │
│  │  │  │  pc2 (Alpine)    │    │       │  gw: 172.18.0.3 (eth1)      │  │  │
│  │  │  │  172.19.0.4      │    │       └──────────────┬───────────────┘  │  │
│  │  │  └──────────────────┘    │                      │                  │  │
│  │  │                          │       ┌──────────────┘                  │  │
│  │  │  gw: 172.19.0.3 (eth0)  │       │                                 │  │
│  │  └──────────────┬───────────┘       │                                 │  │
│  │                 │                   │                                 │  │
│  │                 └────────┬──────────┘                                 │  │
│  │                          │                                            │  │
│  │              ┌───────────▼──────────────┐                             │  │
│  │              │  router (Ubuntu 24.04)   │                             │  │
│  │              │  privileged              │                             │  │
│  │              │  eth0: 172.19.0.3        │                             │  │
│  │              │  eth1: 172.18.0.3        │                             │  │
│  │              │  ip_forward = 1          │                             │  │
│  │              │  iptables FORWARD ACCEPT │                             │  │
│  │              │  MASQUERADE (NAT)        │                             │  │
│  │              └──────────────────────────┘                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│  Security Group: SSH :22 (0.0.0.0/0) — Terraform / t2.large / gp3 20GB     │
└─────────────────────────────────────────────────────────────────────────────┘

Flux inter-VLAN :
  pc1 (172.19.0.2) ──► router eth0 (172.19.0.3) ──► router eth1 (172.18.0.3) ──► pc3 (172.18.0.2)

Pipeline CI/CD :
  GitHub Actions ──► Terraform ──► EC2 ──► Docker Compose ──► Ansible ──► test.sh
```

| Conteneur | Image        | Réseau  | Adresse IP                  | Rôle                    |
|-----------|--------------|---------|------------------------------|-------------------------|
| pc1       | alpine       | vlan10  | 172.19.0.2                   | Poste client VLAN 10    |
| pc2       | alpine       | vlan10  | 172.19.0.4                   | Poste client VLAN 10    |
| pc3       | alpine       | vlan20  | 172.18.0.2                   | Poste client VLAN 20    |
| router    | ubuntu:24.04 | vlan10 + vlan20 | 172.19.0.3 / 172.18.0.3 | Routeur inter-VLAN |

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
docker exec pc1 ping -c 2 172.19.0.4

# Tester la connectivité inter-VLAN (PC1 → PC3 via router)
docker exec pc1 ping -c 2 172.18.0.2

# Vérifier l'IP forwarding
docker exec router sysctl net.ipv4.ip_forward

# Accéder à un container
docker exec -it pc1 sh

# Voir l'état des containers
docker compose ps

# Voir les adresses IP de tous les conteneurs
sudo docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' pc1 pc2 pc3 router
```

## Notes
- L'AMI `ami-0e86e20dae9224db8` est valide pour AWS Academy (us-east-1)
- La clé SSH `vockey` doit être disponible dans votre compte AWS
- Le secret `AWS_SESSION_TOKEN` est obligatoire avec AWS Academy (credentials temporaires)
- Les adresses IP sont attribuées dynamiquement par Docker et peuvent varier à chaque redéploiement


# voir IP de chaque conteneurs
```bash
sudo docker inspect -f '{{.Name}} -> {{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' pc1 pc2 pc3 router

sudo docker exec pc1 ip addr show eth0
sudo docker exec pc2 ip addr show eth0
sudo docker exec pc3 ip addr show eth0
sudo docker exec router ip addr show
```
# Ajout d'un PC4
```bash
# Créer et démarrer pc4 sur le réseau vlan20
sudo docker run -d --name pc4 --network devops-lab_vlan20 alpine sh -c "apk add --no-cache iputils && sleep infinity"

# Vérifier qu'il tourne
sudo docker ps | grep pc4

# Voir son IP
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pc4

# Tester la connectivité avec pc3 (même VLAN)
sudo docker exec pc4 ping -c 2 172.18.0.2
ou sudo docker exec pc4 ping pc3
# Tester la connectivité inter-VLAN avec pc1 (via router)
sudo docker exec pc4 ping -c 2 172.19.0.2
```


# Voir les VLAN
```bash
# Voir tous les réseaux Docker (= tes VLANs)
sudo docker network ls

# Détails du VLAN 10 (conteneurs rattachés, IPs, subnet)
sudo docker network inspect devops-lab_vlan10 ou 
# Raffiné
sudo docker network inspect devops-lab_vlan10 -f '{{range .Containers}}{{.Name}} -> {{.IPv4Address}}{{"\n"}}{{end}}'

# Détails du VLAN 20
sudo docker network inspect devops-lab_vlan20
#Raffiné
sudo docker network inspect devops-lab_vlan20 -f '{{range .Containers}}{{.Name}} -> {{.IPv4Address}}{{"\n"}}{{end}}'
```
