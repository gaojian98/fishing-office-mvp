FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

WORKDIR /app/fishing_office_flutter
COPY fishing_office_flutter/pubspec.yaml ./
COPY fishing_office_flutter/pubspec.lock ./
RUN flutter pub get

COPY fishing_office_flutter ./
RUN flutter build web --release

FROM node:20-alpine AS runtime

WORKDIR /app
COPY server.js ./server.js
COPY --from=flutter-builder /app/fishing_office_flutter/build/web ./fishing_office_flutter/build/web

ENV PORT=3000
EXPOSE 3000

CMD ["node", "server.js"]
