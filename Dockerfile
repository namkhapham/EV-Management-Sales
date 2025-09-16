# Stage 1: Build Flutter web app
FROM debian:bullseye AS build

# Cài các gói cần thiết
RUN apt-get update && apt-get install -y \
    curl unzip xz-utils git wget libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Cài Flutter SDK
WORKDIR /app
RUN git clone https://github.com/flutter/flutter.git -b stable
ENV PATH="/app/flutter/bin:/app/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Bật Flutter web
RUN flutter config --enable-web

# Copy source code vào container
COPY . .

# Tải dependencies
RUN flutter pub get

# Build bản web release
RUN flutter build web --release

# Stage 2: Runtime (Nginx để chạy web)
FROM nginx:alpine AS runtime

# Copy build web từ stage 1 sang Nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Mở cổng 80
EXPOSE 80

# Chạy web
CMD ["nginx", "-g", "daemon off;"]
