# Création d’une Vente dans Lemadio – Guide Complet

**Mots-clés** : créer vente, nouvelle vente, vente directe, vente revendeur, approvisionnement, comment faire une vente

## Point de départ commun
Après connexion, tu arrives directement sur la page **Ventes**.

**Pour démarrer une nouvelle vente** → clique sur le **bouton rond vert avec le +** en bas à droite.

Deux choix s’affichent :
- Vente Directe → vente à un client final
- Vente Revendeur → approvisionnement d’un revendeur ADES

## 1. Vente Directe (Client Final) – Étapes détaillées

**Flux complet** : Informations client → N° facture → Vérification → Scan réchauds → Conditions & signature → Enregistré

### Étape 1 – Saisie des informations client (champs obligatoires sauf CIN)
- Catégorie : Private / Hôtel / École / ONG / Restaurant / Hôpital / Microbusiness / Prison  
- Cluster (type de réchaud) : Charcoal / Wood / Solar + OLI-b / Solar + OLI-c  
- Civilité : Mme / Mr  
- Nom + Prénom (ou surnom)  
- Téléphone  
- Adresse complète  
- Géolocalisation : clique l’icône GPS → position automatique ou déplace le marqueur rouge  
- CIN (facultatif) : photo recto + verso

→ Valider

### Étape 2 – Choix du numéro de facture
Recherche et sélection d’un seul numéro disponible → Valider

### Étape 3 – Récapitulatif client
Vérifie tout avec le client → bouton Retour si besoin → Valider

### Étape 4 – Scan des réchauds
1. Clique le boutob dans le cadre jaune « Scanner »
2. Scanne chaque code-barres
3. Le réchaud doit être dans ton stock local
4. Prix automatique selon la zone du client (Zone riche / Moyenne / LNOB)
5. Tableau récapitulatif (Type / Prix unitaire / Quantité / Total) → Valider

### Étape 5 – Conditions de garantie & signature
1. Le client lit les conditions (garantie 3 ans, exclusions, grilles gratuites, certificat CO)
2. Cocher « J’accepte de céder le droit de ce dossier »
3. Signature sur le pad (icône poubelle pour effacer)
→ Enregistrer → Vente terminée avec succès

## 2. Vente Revendeur (Approvisionnement ADES) – Étapes rapides

**Flux** : N° facture → Choix du revendeur → Scan réchauds → Conditions & signature → Enregistré

1. Sélectionne un numéro de facture disponible → Valider
2. Choisis le revendeur dans la liste de ton centre → Valider
3. Scan des réchauds (identique à la vente directe)
4. Conditions & signature (identique à la vente directe)
→ Vente enregistrée

## Synchronisation des ventes (très important)

| Statut                  | Description                                      | Indicateur                     |
|-------------------------|--------------------------------------------------|--------------------------------|
| Synchronisée            | Enregistrée localement + envoyée sur Salesforce  | Carte verte + « Synchronisé » |
| Non synchronisée (hors ligne) | Enregistrée localement seulement            | Carte orange + badge Ventes   |

**Pour synchroniser manuellement** :
1. Connexion internet
2. Page Ventes
3. Menu ⋮ → Synchroniser

## Liste complète des modèles de réchauds ADES

| Modèle     | Combustible | Taille      | Description               |
|------------|-------------|-------------|---------------------------|
| OLI-c      | Charbon     | Petit       |                           |
| OLI-b      | Bois        | Petit       |                           |
| OLI-45c    | Charbon     | Moyen       |                           |
| OLI-45b    | Bois        | Moyen       |                           |
| OLI-60c    | Charbon     | Grand       |                           |
| OLI-60b    | Bois        | Grand       |                           |
| Box        | Multifonction | -         |                           |
| Parabole   | Solaire     | -           | Réflecteur solaire        |

**Résumé ultra-rapide pour l’assistant** :
Pour créer une vente → bouton + vert → choisir Vente Directe ou Revendeur → remplir les étapes → scanner → signature → terminé.