# Use the official PHP image as the base image
FROM php:8.2-fpm

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

# Generate the Laravel application key

