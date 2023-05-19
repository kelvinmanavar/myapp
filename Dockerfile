FROM debian:buster

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
        unzip \
        libonig-dev \
        libzip-dev \
        libpng-dev \
        libxml2-dev \
        supervisor

# Install PHP 8.2
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y php8.2-fpm php8.2-cli php8.2-mbstring php8.2-xml php8.2-zip php8.2-mysql php8.2-gd php8.2-curl php8.2-redis

# Install Nginx
RUN apt-get install -y nginx

# Copy Laravel application files
COPY . /var/www/html

# Set up Nginx configuration
COPY /nginx/nginx.conf /etc/nginx/sites-available/default
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
CMD [nginx && php-fpm]

