# DevOps Network Lab V2 (AWS Academy Ready)

## Stack
- AWS EC2 (Terraform)
- Docker Compose
- Ansible
- GitHub Actions

## Architecture
- **PC1 & PC2** : Containers Alpine sur VLAN 10
- **PC3** : Container Alpine sur VLAN 20
- **Router** : Ubuntu avec IP forwarding et iptables

## Secrets GitHub requis
Avant de pusher, configurez ces secrets dans les paramètres de votre repo GitHub :

- `AWS_ACCESS_KEY_ID` : Votre clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY` : Votre clé secrète AWS
- `AWS_DEFAULT_REGION` : Région AWS (us-east-1)
- `EC2_SSH_PRIVATE_KEY` : Votre clé SSH privée pour EC2 (format PEM)

## Usage

### Déploiement automatique
```bash
git push origin main
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
# Tester la connectivité entre PC1 et PC3
docker exec pc1 ping pc3

# Vérifier l'IP forwarding
docker exec router sysctl net.ipv4.ip_forward

# Accéder à un container
docker exec -it pc1 sh
```

## Notes
- Mettez à jour `YOUR_REPO` dans le fichier `deploy.yml` avec votre URL de repo
- L'AMI `ami-0e86e20dae9224db8` est valide pour AWS Academy (us-east-1)
- La clé SSH `vockey` doit être disponible dans votre compte AWS
