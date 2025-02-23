FROM nginx:latest

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Copy website files
COPY ./src /usr/share/nginx/html

# Expose port 80
EXPOSE 80
