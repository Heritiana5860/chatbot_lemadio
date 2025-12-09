# Création d'une Vente dans Lemadio

**Vente Directe (client final) et Vente Revendeur (approvisionnement ADES)**

Ce guide détaille les deux types de vente possibles dans l'application Lemadio.

## Point de départ commun

Après une connexion réussie, la **page des ventes** s'ouvre automatiquement.

### Démarrer une nouvelle vente

- Cliquez sur le **bouton rond vert « + »** (en haut à droite de la barre de navigation inférieure).
- Deux options apparaissent :
  - **Vente Revendeur** → Approvisionnement d'un revendeur ADES
  - **Vente Directe** → Vente à un client final

### Réponse recommandée de l'Assistant Lemadio

Lorsque l'utilisateur demande : « Comment créer une vente ? » ou « Je veux faire une vente »

→ **Assistant :** Pour vous aider au mieux, précisez svp le type de vente souhaité :

- Une **Vente Directe** (client final)
- Une **Vente Revendeur** (approvisionnement d'un revendeur ADES)

## 1\. Processus - Vente Directe (Client Final)

### Schéma du flux

Page Ventes → Informations Client → Sélection Facture → Vérification Client → Scan Réchaud(s) → Conditions & Signature → Enregistrer

### Étape 1 - Informations Client (tous les champs obligatoires sauf CIN)

- **Catégorie** : Private / Hotel / Ecole / NGO / Restaurant / Hopital / Microbusiness / Prison
- **Cluster** (type de réchaud vendu) : Charcoal / Wood / Solar + OLI-b / Solar + OLI-c
- **Identité** : Civilité (Mme/Mr), Nom, Prénom (surnom), Contact (téléphone), Adresse complète
- **Localisation** : - Cliquez sur l'icône de géolocalisation → carte OpenStreetMap - Position actuelle récupérée automatiquement - Possibilité de recherche manuelle (Fokontany, Région…) - Placer le marqueur rouge à l'emplacement exact - Corriger manuellement les champs si « Non spécifié » apparaît
- **CIN** (facultatif) : photo recto + verso → Cliquez sur **Valider**

### Étape 2 - Sélection du numéro de facture

- Choisir **un seul** numéro de facture disponible (filtre via barre de recherche) → **Valider**

### Étape 3 - Vérification des informations client

- Récapitulatif complet des données saisies
- Confirmer avec le client
- Bouton retour si correction nécessaire → **Valider**

### Étape 4 - Scan des réchauds

- Cliquez sur le bouton scanner (cadre jaune)
- Scanner le code-barres de chaque réchaud
- Vérification automatique : le réchaud doit être présent dans votre stock local
- Association **prix + zone géographique** du client :
  - Zone riche / Zone moyenne / Zone LNOB
  - Prix unitaire adapté au type de réchaud + zone
- Tableau récapitulatif (Type, Prix unitaire, Quantité, Total) → **Valider**

### Étape 5 - Conditions de garantie & Signature

- Lecture des conditions de garantie (3 ans, exclusions, grilles supplémentaires gratuites, certificats CO propriété ADES)
- Cocher « J'accepte de céder le droit de ce dossier »
- Signature du client sur le pad (icône poubelle pour effacer) → **Enregistrer** → vente finalisée

## 2\. Processus - Vente Revendeur (Approvisionnement ADES)

### Schéma du flux

Page Ventes → Sélection Facture → Sélection Revendeur → Scan Réchaud(s) → Conditions & Signature → Enregistrer

### Étape 1 - Sélection du numéro de facture

- Choisir un numéro disponible → **Valider**

### Étape 2 - Sélection du revendeur

- Liste des revendeurs rattachés au centre de vente
- Sélectionner le revendeur concerné → **Valider**

### Étape 3 - Scan des réchauds

### Étape 4 - Conditions & Signature

## Gestion de la synchronisation

| **Statut**             | **Description**                                     | **Indicateur**                                              |
| ---------------------- | --------------------------------------------------- | ----------------------------------------------------------- |
| Vente synchronisée     | Enregistrée localement + envoyée sur Salesforce     | Carte verte « Synchronisé » - Réchaud marqué « vendu »      |
| Vente non synchronisée | Enregistrée localement seulement (pas de connexion) | Carte orange « Non synchronisé » - Badge sur l'icône Ventes |

### Synchronisation manuelle (ventes hors ligne)

- Connexion Internet requise
- Aller sur la page Ventes
- Vérifier les cartes orange
- Menu (trois points verticaux) → **Synchroniser**

## Types de réchauds commercialisés par ADES

| **Modèle** | **Combustible** | **Format / Description** |
| ---------- | --------------- | ------------------------ |
| OLI-c      | Charbon         | Petit format             |
| OLI-b      | Bois            | Petit format             |
| OLI-45c    | Charbon         | Moyen format             |
| OLI-45b    | Bois            | Moyen format             |
| OLI-60c    | Charbon         | Grand format             |
| OLI-60b    | Bois            | Grand format             |
| Box        | Multifonction   | -                        |
| Parabole   | Solaire         | Réflecteur solaire       |
