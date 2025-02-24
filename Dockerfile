FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy static files from a remote URL
ADD https://www.free-css.com/assets/files/free-css-templates/download/page2/ost-magazine.zip /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
