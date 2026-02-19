FROM php:8.1-apache

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    git curl unzip \
    libicu-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libxml2-dev libzip-dev libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd intl mysqli pdo_mysql opcache zip soap mbstring exif

# Descargar Moodle
RUN cd /tmp && \
    curl -fSL https://download.moodle.org/download.php/direct/stable404/moodle-4.4.tgz -o moodle.tgz && \
    tar -xzf moodle.tgz -C /var/www/html --strip-components=1 && \
    rm moodle.tgz

# Crear directorio de datos
RUN mkdir -p /var/moodledata && \
    chown -R www-data:www-data /var/www/html /var/moodledata && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /var/moodledata

# Configurar PHP
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle.ini && \
    echo "upload_max_filesize = 200M" >> /usr/local/etc/php/conf.d/moodle.ini && \
    echo "post_max_size = 200M" >> /usr/local/etc/php/conf.d/moodle.ini && \
    echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/moodle.ini

# Habilitar mod_rewrite
RUN a2enmod rewrite

WORKDIR /var/www/html
