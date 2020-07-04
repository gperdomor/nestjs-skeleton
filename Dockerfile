FROM node:14.5-alpine as development
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:14.5-alpine as production
LABEL maintainer="Gustavo Perdomo <gperdomor@gmail.com>"
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
RUN addgroup -S nestjs && adduser -S nestjs -G nestjs
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY --from=development /usr/src/app/dist .
COPY tools/scripts/docker-entrypoint.sh /usr/local/bin/
RUN apk add --no-cache bash
RUN chown -R nestjs:nestjs /usr/src/app
ENTRYPOINT ["docker-entrypoint.sh"]
USER nestjs
CMD ["node", "main"]
