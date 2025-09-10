FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy compiled Flutter web app
COPY build/web /usr/share/nginx/html

# Copy custom nginx config if present
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Use the default nginx entrypoint
CMD ["nginx", "-g", "daemon off;"]
