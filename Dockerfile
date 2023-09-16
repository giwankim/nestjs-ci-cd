FROM node:18.17.1-bookworm-slim AS base
ENV NODE_ENV=production
RUN apt-get update \
    && apt-get -qq install -y --no-install-recommends \
    tini \
    tzdata \
    && rm -rf /var/lib/apt/lists/* \
# Locale Setting
ENV LC_ALL C.UTF-8
# Set timezone
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone \
    dpkg-reconfigure -f noninteractive tzdata \
EXPOSE 3000
RUN mkdir /app && chown -R node:node /app
WORKDIR /app
USER node
COPY --chown=node:node package*.json yarn*.lock ./
RUN npm ci --omit-dev && npm cache clean --force

FROM base AS dev
ENV NODE_ENV=development
ENV PATH=/app/node_modules/.bin:$PATH
RUN npm install && npm cache clean --force
CMD [ "npm", "run", "start:dev" ]

FROM dev AS build
COPY --chown=node:node . .
RUN npm run build

FROM base AS prod
COPY --from=build /app/dist ./dist
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "./dist/main.js"]
