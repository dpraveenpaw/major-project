FROM nginx:alpine
COPY ./wave-cafe /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
