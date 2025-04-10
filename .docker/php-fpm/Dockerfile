FROM wordpress:6-fpm-alpine

# Install msmtp
RUN apk --no-cache add msmtp

COPY .docker/php-fpm/custom.ini $PHP_INI_DIR/conf.d/

# Configure sendmail path
RUN echo "sendmail_path = /usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini
