# Stage 1: Build Flutter web app
FROM debian:bullseye AS build

RUN apt-get update && apt-get install -y \
    curl unzip xz-utils git wget libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/flutter/flutter.git -b stable
ENV PATH="/app/flutter/bin:/app/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter config --enable-web

COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Runtime (Nginx để chạy web)
FROM nginx:alpine AS runtime

# Copy build web từ stage 1 sang Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy file config Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
