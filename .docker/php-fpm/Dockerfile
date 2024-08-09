FROM wordpress:6-fpm-alpine

# Install msmtp
RUN apk --no-cache add msmtp

# Configure sendmail path
RUN echo "sendmail_path = /usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini