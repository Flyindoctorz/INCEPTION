#!/bin/bash

# Script pour mettre à jour Docker vers la dernière version
# Usage: ./update_docker.sh

set -e

echo "=== Mise à jour de Docker ==="
echo ""

# Désinstaller les anciennes versions
echo "[1/6] Désinstallation des anciennes versions de Docker..."
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Mettre à jour les paquets
echo "[2/6] Mise à jour des paquets système..."
sudo apt update

# Installer les dépendances
echo "[3/6] Installation des dépendances..."
sudo apt install -y ca-certificates curl gnupg lsb-release

# Ajouter la clé GPG officielle de Docker
echo "[4/6] Ajout de la clé GPG de Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajouter le dépôt Docker
echo "[5/6] Ajout du dépôt Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
echo "[6/6] Installation de Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Ajouter l'utilisateur au groupe docker
echo ""
echo "Ajout de l'utilisateur au groupe docker..."
sudo usermod -aG docker $USER

# Vérifier l'installation
echo ""
echo "=== Installation terminée ==="
docker --version
docker compose version

echo ""
echo "⚠️  IMPORTANT: Déconnecte-toi et reconnecte-toi pour appliquer les changements de groupe !"
echo "Ou exécute: newgrp docker"