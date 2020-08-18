FROM debian:buster

# MAINTAINER ssummers <ssummers@student.42.fr>

RUN apt-get update && apt-get install -y procps && apt-get install nano && apt-get install -y wget
RUN apt-get -y install php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-soap php7.3-imap
RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server

RUN chown -R www-data /var/www/* \
	&& chmod -R 755 /var/www/* \
	&& mkdir /etc/nginx/ssl \
	&& openssl req -newkey rsa:2048 -nodes -out /etc/ssl/certs/certificate.crt \
                                           		-keyout /etc/ssl/certs/key.key -x509 -days 365 -subj "/C=RU/ST=Tatarstan/L=Kazan/O=21school/OU=21/CN=ssummers"

COPY srcs/nginx.conf /etc/nginx/sites-available/

RUN rm -rf /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/sites-available /etc/nginx/sites-enabled

RUN service mysql start \
	&& echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password \
	&& echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password \
	&& echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password \
	&& echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password

RUN mkdir /var/www/phpmyadmin \
	&& wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz \
	&& tar -xvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components 1 -C /var/www/phpmyadmin \
	&& rm phpMyAdmin-4.9.0.1-all-languages.tar.gz

COPY srcs/phpmyadmin.inc.php /var/www/phpmyadmin/config.inc.php

RUN wget -c https://wordpress.org/latest.tar.gz \
	&& tar -xvzf latest.tar.gz \
	&& mv wordpress/ /var/www \
	&& rm latest.tar.gz

COPY srcs/wp-config.php /var/www/wordpress

EXPOSE 80/tcp 443/tcp

RUN service php7.3-fpm start
RUN service nginx start

COPY srcs/start.sh /var/
COPY srcs/autoindex.sh .
CMD bash /var/start.sh