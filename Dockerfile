FROM alpine:latest

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1
  
RUN apk --update add \
  nginx \
  php7 \
  php7-fpm \
  php7-pdo \
  php7-json \
  php7-mysqli \
  php7-pdo_mysql \
  php7-phar \
  php7-mbstring \
  php7-zmq \
  curl \
  supervisor

RUN mkdir -p /etc/nginx && \
	mkdir -p /var/run/php-fpm && \
	mkdir -p /var/run/nginx && \
	mkdir -p /var/log/supervisor

RUN rm /etc/nginx/conf.d/default.conf
RUN rm /etc/php7/php-fpm.d/www.conf

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer
RUN composer dump-autoload --optimize

COPY . ./
RUN chown -R www-data:www-data /app/www

WORKDIR /app

ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/nginx_app.conf /etc/nginx/conf.d/nginx_app.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/www.conf /etc/php7/php-fpm.d/www.conf

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]