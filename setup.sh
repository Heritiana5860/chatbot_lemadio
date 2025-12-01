#!/bin/bash

echo "🚀 Installation du système de formation Lemadio - Phase 1"
echo "========================================================"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

echo "✅ Docker et Docker Compose détectés"

# Créer la structure des dossiers
echo ""
echo "📁 Création de la structure des dossiers..."
mkdir -p backend/documents
mkdir -p frontend

echo "✅ Structure créée"

# Construire et démarrer les services
echo ""
echo "🐳 Démarrage des conteneurs Docker..."
docker-compose up -d

echo ""
echo "⏳ Attente du démarrage des services (30 secondes)..."
sleep 30

# Télécharger le modèle Mistral dans Ollama
echo ""
echo "📥 Téléchargement du modèle Mistral (cela peut prendre plusieurs minutes)..."
docker exec lemadio_ollama ollama pull mistral

echo ""
echo "✅ Installation terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Placez vos documents .docx dans le dossier: ./documents/"
echo "2. Redémarrez le backend: docker-compose restart backend"
echo "3. Accédez à l'API: http://localhost:8080"
echo "4. Testez avec: http://localhost:8080/health"
echo ""
echo "🔧 Commandes utiles:"
echo "  - Voir les logs: docker-compose logs -f backend"
echo "  - Arrêter: docker-compose down"
echo "  - Redémarrer: docker-compose restart"
echo ""