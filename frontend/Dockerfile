# # Stage 1: Build the React app
# FROM node:20-alpine AS builder

# WORKDIR /app

# # Copier les fichiers de dépendances
# COPY package*.json ./
# RUN npm install --legacy-peer-deps

# # Copier tout le code source
# COPY . .

# # Build avec les variables d'environnement
# ARG REACT_APP_API_URL=http://localhost:8080
# ENV REACT_APP_API_URL=$REACT_APP_API_URL

# RUN npm run build

# # Stage 2: Serve with nginx
# FROM nginx:alpine

# # Copier les fichiers buildés
# COPY --from=builder /app/dist /usr/share/nginx/html

# # Copier la configuration nginx personnalisée
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]

# frontend/Dockerfile  ← remplace complètement l’ancien en dev
FROM node:20-alpine

WORKDIR /app

# Copie seulement les fichiers de dépendances pour profiter du cache
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copie le code source (sera écrasé par le volume, mais nécessaire pour le premier build)
COPY . .

# Vite écoute sur le port 5173 en mode dev
EXPOSE 5173

# Hot-reload activé + accessible depuis l'extérieur
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]