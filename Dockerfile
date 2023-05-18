# Use the official PHP image as the base image
FROM php:7.4-fpm

# Set the working directory in the container
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        zip \
        unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Copy the project files to the working directory in the container
COPY . .

# Set the correct file permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Install composer and run the composer install command
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-interaction --no-scripts --no-dev --prefer-dist

# Generate the Laravel application key
RUN php artisan key:generate
CMD ["php-fpm"]
# Use the official Nginx image as the base image
FROM nginx:latest

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for Nginx
EXPOSE 80

# Start both PHP-FPM and Nginx
CMD ["nginx"]
