# Étape 1 : Builder Flutter Web
FROM dart:stable AS builder
WORKDIR /app
COPY . .

# Activer Flutter Web (si besoin)
RUN flutter config --enable-web

# Télécharger dépendances
RUN flutter pub get

# Build web
RUN flutter build web

# Étape 2 : Image finale avec NGINX
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copier le build Flutter web
COPY --from=builder /app/build/web /usr/share/nginx/html

# Optionnel : config nginx custom
COPY nginx.conf /etc/nginx/conf.d/default.conf