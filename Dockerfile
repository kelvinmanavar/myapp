FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        apt-transport-https \
        software-properties-common \
        git \
        zip \
        unzip \
        libonig-dev \
        libzip-dev \
        libpng-dev \
        libxml2-dev \
        supervisor 
        
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd        

# Install PHP 8.2
COPY composer.lock composer.json /var/www/html/
# apt-get install -y php8.2-cli php8.2-mbstring php8.2-xml php8.2-zip php8.2-mysql php8.2-gd php8.2-curl php8.2-redis

RUN php -d memory_limit=2048M /usr/local/bin/composer update
# Copy Laravel application files
COPY . /var/www/html

# Set up Nginx configuration

RUN cp .env.example .env
# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel dependencies


# Set permissions for Laravel storage and bootstrap cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

RUN chown -R www-data:www-data storage bootstrap/cache

# Generate the Laravel application key


# Expose port 80
EXPOSE 80

# Start PHP-FPM and Nginx
CMD [php-fpm]

