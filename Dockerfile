FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

WORKDIR /app

COPY . .
WORKDIR /app/fishing_office_flutter
RUN flutter pub get && flutter build web --release

FROM node:20-alpine AS runtime

WORKDIR /app

COPY fishing_office_flutter/server.js ./server.js
COPY --from=flutter-builder /app/fishing_office_flutter/build/web ./build/web

ENV PORT=3000

EXPOSE 3000

CMD ["node", "server.js"]
