FROM php:8.5-fpm

# Instalar Node.js 20 LTS y dependencias del sistema
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y \
    git curl unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    libicu-dev libmariadb-dev libgd-dev libjpeg-dev libfreetype-dev libwebp-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd intl zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Composer oficial
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Habilitar Corepack e instalar pnpm (gestor de paquetes seguro y aislado)
RUN corepack enable && corepack prepare pnpm@latest --activate

# Configuración PHP
COPY php/local.ini /usr/local/etc/php/conf.d/local.ini

# Configuración pnpm recomendada para ecosistema Laravel/Bagisto
COPY .npmrc /var/www/html/.npmrc

WORKDIR /var/www/html

# Permisos y estructura base
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage/framework/{cache,sessions,views} \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]