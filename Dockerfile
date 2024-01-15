FROM node:19-alpine3.15 as dev
WORKDIR /app
COPY package.json ./
RUN npm install
CMD [ "npm","run","start:dev" ]

FROM node:16-alpine3.16 as dev-deps
WORKDIR /app
COPY package*.json .
RUN npm install

FROM node:16-alpine3.16 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules /app/node_modules
COPY . .
RUN npm run test
RUN npm run build

FROM node:16-alpine3.16 as prod-deps
WORKDIR /app
COPY package*.json .
RUN npm install --produccion

FROM node:16-alpine3.16 as prod
EXPOSE 3000
WORKDIR /app
ENV APP_VERSION=${APP_VERSION}
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=builder /app/dist ./dist
CMD [ "node","dist/main.js" ]






