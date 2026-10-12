FROM php:8.3-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql mysqli

WORKDIR /var/www/html

COPY index.php .

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
