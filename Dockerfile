# screenly
FROM php:7.3-fpm
MAINTAINER Michael Both <both.michael@googlemail.com>
LABEL image="ionphractal/screeenly" \
  version="0.1.1" \
  description="Docker Container with Screeenly." \
  package="Screeenly" \
  package_url="https://github.com/stefanzweifel/screeenly" \
  package_version="2.1.1"

ENV PKG_NAME="screeenly" \
  PKG_VERSION="v2.1.1" \
  PKG_GIT_URL="https://github.com/gogits/gogs.git" \
  PKG_COMMIT="2205420981b8b2dcdb24696d1bae46f36b929191" \
  DEBIAN_FRONTEND="noninteractive"

WORKDIR /var/www/

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y ca-certificates fonts-liberation gconf-service git gnupg libappindicator1 libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libfreetype6-dev libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libjpeg62-turbo-dev libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libpng-dev libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils zip \
  gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
 && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && apt-get install -y nodejs npm

RUN docker-php-ext-install -j$(nproc) iconv \
 apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# && apt-get install -y libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev \
# && docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
#    --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir \
#    --enable-gd-native-ttf \
# && docker-php-ext-install gd \
# && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \

RUN  docker-php-ext-install -j$(nproc) pdo pdo_mysql pdo_pgsql \
 && rm -R /var/www/html \
 && git clone https://github.com/stefanzweifel/screeenly.git . \
 && git checkout master \
 && npm install --global yarn envsub \
 && npm install --global --unsafe-perm puppeteer \
 && chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium \
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && apt-get clean -y \
 && rm -rf .git /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && rm /var/log/lastlog /var/log/faillog .gitattributes .gitignore .travis.yml CODE_OF_CONDUCT.md composer-setup.php \
 && chown -R www-data: /var/www/

USER www-data
RUN composer install \
 && yarn install
#RUN npm install

ADD entrypoint.sh /
ADD env.template /var/www/
COPY etc /usr/local/etc

# initial setup
CMD ["bash", "/entrypoint.sh"]
