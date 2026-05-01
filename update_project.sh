#!/bin/bash

echo "🚀 Mise à jour DevOps Lab - Terraform & Workflow"
echo "================================================"
echo ""

# Vérifier qu'on est dans le bon dossier
if [ ! -d ".git" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet"
    echo "   cd ~/devops-network-lab && bash update_project.sh"
    exit 1
fi

echo "📁 Vérification de la structure..."

# Créer les dossiers s'ils n'existent pas
mkdir -p terraform
mkdir -p .github/workflows

echo "✓ Dossiers vérifiés"
echo ""

# Les fichiers à copier sont fournis ci-dessous
# Vous devez les remplacer par les versions corrigées

echo "📋 À faire manuellement :"
echo "1. Téléchargez les fichiers corrigés :"
echo "   - terraform/variables.tf"
echo "   - terraform/main.tf (REMPLACEZ l'ancien)"
echo "   - terraform/outputs.tf"
echo "   - .github/workflows/deploy.yml (REMPLACEZ l'ancien)"
echo ""
echo "2. Mettez à jour vos secrets GitHub :"
echo "   Settings → Secrets and variables → Actions"
echo "   Assurez-vous d'avoir :"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - AWS_SESSION_TOKEN ⭐ (IMPORTANT)"
echo "   - AWS_DEFAULT_REGION = us-east-1"
echo "   - EC2_SSH_PRIVATE_KEY"
echo ""
echo "3. Puis exécutez :"
echo "   git add terraform/ .github/workflows/"
echo "   git commit -m 'Update Terraform and workflow for better AWS handling'"
echo "   git push origin master"
echo ""
echo "✓ Script complété!"
