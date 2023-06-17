FROM node as build
WORKDIR /app
COPY . .
RUN npm install --legacy-peer-deps
RUN npm run build

FROM nginxinc/nginx-unprivileged
COPY --chown=nginx:nginx --from=build /app/public /usr/share/nginx/html