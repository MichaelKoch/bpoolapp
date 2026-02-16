FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY assets/.well-known /usr/share/nginx/html/.well-known

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
