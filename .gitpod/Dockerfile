FROM gitpod/workspace-full:latest

# Change your version here
# problems with loading extensions in 7.4
# RUN sudo update-alternatives --set php $(which php7.4)

RUN sudo apt-get update && sudo apt-get install -y php8.1-gd php8.1-mysql

RUN brew install lazygit

COPY ops/build/apache-gitpod.conf /etc/apache2/apache2.conf
COPY ops/build/php-gitpod.ini /etc/php/8.1/cli/php-custom.ini

# optional: change document root folder. It's relative to your git working copy.
ENV APACHE_DOCROOT_IN_REPO="app/html"

# change php version
RUN sudo update-alternatives --set php $(which php8.1)

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && sudo mv wp-cli.phar /usr/local/bin/wp

# DOPPLER
RUN sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg \
    && curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add - \
    && echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list \
    && sudo apt-get update \
    && sudo apt-get install -y doppler