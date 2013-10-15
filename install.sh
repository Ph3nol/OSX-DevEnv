#!/usr/bin/env bash

### YOUR CONFIRUATION ########################################################################

CLI_PACKAGES="bash wget curl ack grep tree lynx imagemagick"

ZSH=1
GIT=1
    GIT_AUTHOR_NAME="Cédric Dugat"
    GIT_AUTHOR_EMAIL="cedric@dugat.me"

APACHE_CONFIG=1 # No installation with Brew, just configuration (parameters and vhosts)
    APACHE_CONF_FILEPATH="/private/etc/apache2/httpd.conf"
PHP=1
    PHP_VERSIONS_TO_INSTALL="5.4 5.5"
    PHP_DEFAULT_VERSION="5.4"
    PHP_CUSTOMIZE_PHPINI=1
        PHP_DATE_TIMEZONE="Europe\/Paris"
        PHP_MEMORY_LIMIT="512M"
        PHP_POST_MAX_SIZE="64M"
        PHP_UPLOAD_MAX_FILESIZE="64M"
        PHP_MAX_EXECUTION_TIME="300"
        PHP_MAX_INPUT_TIME="600"
        PHP_XDEBUG_MAX_NESTING_LEVEL="500"
        PHP_MODULES_TO_INSTALL="apc memcached xdebug intl xhprof mcrypt
        imagick posix curl iconv openssl"
    COMPOSER=1
MYSQL=1
    MYSQL_AT_START=1
    PHPMYADMIN=1
POSTGRESQL=0
MONGODB=1
    MONGODB_AT_START=1
REDIS=1
    REDIS_AT_START=1
MEMCACHED=1
ELASTICSEARCH=1
    ELASTICSEARCH_AT_START=1
RABBITMQ=1
    RABBITMQ_AT_START=1
NODE_NPM=1
METEOR=1

GEMS_TO_INSTALL="capistrano capifony mailcatcher compass"
NPM_PACKAGES_TO_INSTALL="bower less sails yo generator-webapp generator-angular
    meteor meteorite generator-meteor"

OSX_PACKAGES=1
    OSX_PACKAGES_TO_INSTALL="dropbox google-chrome google-chrome-canary google-drive iterm2
    sublime-text the-unarchiver virtualbox vagrant gas-mask vlc adium dashlane growlnotify
    app-cleaner ccleaner clean-my-mac cloudapp command-q evernote filezilla mou mysql-workbench
    robomongo sequel-pro skype spotify team-viewer u-torrent spectacle xtra-finder"















##############################################################################################
##############################################################################################
##############################################################################################
##                                                                                          ##
##                                  DO NOT TOUCH FROM HERE!                                 ##
##                                                                                          ##
##############################################################################################
##############################################################################################
##############################################################################################

### LOGICAL FUNCTIONS ########################################################################

homebrewPreparation() {
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
    READY_TO_BREW=$(brew doctor 2>&1)

    if [ "$READY_TO_BREW" != "Your system is ready to brew." ]; then
        echo -e "\n\033[33m✘\033[31m Brew Doctor failed."
        echo -e "  Run 'brew doctor', fix errors before relaunching this script.\033[0m\n"
        exit 0
    fi

    echo -e "\n\033[33m✔\033[33m Updating and upgrading Brew...\033[0m\n"
    brew update
    brew upgrade

    echo -e "\n\033[33m✔\033[33m Tapping Brew formulaes...\033[0m\n"
    brew tap homebrew/dupes
    brew tap josegonzalez/homebrew-php
}

environmentPreparation() {
    DEV_PROFILE_FILEPATH=~/.profile.dev
    [ -f $DEV_PROFILE_FILEPATH ] || touch $DEV_PROFILE_FILEPATH
    brew install grep wget autoconf icu4c
}

cliPackagesHandler() {
    for CLI_PACKAGE in $CLI_PACKAGES
    do
        brew install $CLI_PACKAGE
    done
}

gitHandler() {
    brew install git
    git config --global user.name "$GIT_AUTHOR_NAME"
    git config --global user.email $GIT_AUTHOR_EMAIL
}

zshHandler() {
    brew install zsh
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
    chsh -s /bin/zsh
}

apacheConfigHandler() {
    sudo kill -9 `ps -ef | grep "httpd\|apache" | grep -v grep | awk '{print $2}'`
    APACHE_USER=`whoami`

    [ -d ~/Sites/apache ] || mkdir ~/Sites/apache
    [ -d ~/Sites/logs ] || mkdir ~/Sites/logs
    [ -d ~/Sites/vhosts ] || mkdir ~/Sites/vhosts
    [ -f ~/Sites/vhosts/index.html ] || touch ~/Sites/vhosts/index.html

    if [ ! -f ~/Sites/apache/__default__.conf ]; then
        echo -e "<VirtualHost _default_:80>\n    DocumentRoot /Users/$APACHE_USER/Sites/vhosts\n</VirtualHost>" \
            > ~/Sites/apache/__default__.conf
    fi

    sudo sed -i "" -e "s/^\(<Directory \).*\(>\)$/\1\"\/Users\/$APACHE_USER\/Sites\/vhosts\"\2/g" \
        $APACHE_CONF_FILEPATH
    sudo sed -i "" -e "s/^\(DocumentRoot\) .*$/\1 \"\/Users\/$APACHE_USER\/Sites\/vhosts\"/g" \
        $APACHE_CONF_FILEPATH
    sudo sed -i "" -e "s/^\(#\)\(ServerName\) .*$/\2 localhost/g" $APACHE_CONF_FILEPATH
    sudo sed -i "" -e "s/^\(User\) .*$/\1 $APACHE_USER/g" $APACHE_CONF_FILEPATH
    sudo sed -i "" -e "s/^\(Group\) .*$/\1 staff/g" $APACHE_CONF_FILEPATH

    if ! grep -q -m 1 \
        "# OSX Dev environement parameters" $APACHE_CONF_FILEPATH; then
            sudo bash -c \
                "echo -e '\n# OSX Dev environement parameters ########\n' >> $APACHE_CONF_FILEPATH"
    fi

    if ! grep -q -m 1 \
        "NameVirtualHost \*:80" $APACHE_CONF_FILEPATH; then
            sudo bash -c "echo 'NameVirtualHost *:80' \
                >> $APACHE_CONF_FILEPATH"
    fi

    if ! grep -q -m 1 \
        "Include /Users/$APACHE_USER/Sites/apache/\*.conf" $APACHE_CONF_FILEPATH; then
            sudo bash -c "echo -e 'Include /Users/$APACHE_USER/Sites/apache/*.conf' \
                >> $APACHE_CONF_FILEPATH"
    fi

    sudo apachectl restart
}

mysqlHandler() {
    sudo kill -9 `ps -ef | grep "mysql" | grep -v grep | awk '{print $2}'`
    brew install mysql
    if [ $MYSQL_AT_START -eq 1 ]; then
        ln -sfv $HOMEBREW_BASEPATH/opt/mysql/*.plist ~/Library/LaunchAgents
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
    fi
}

postgreSqlHandler() {
    sudo kill -9 `ps -ef | grep "postgre" | grep -v grep | awk '{print $2}'`
    brew install postgresql --without-ossp-uuid
}

mongodbHandler() {
    sudo kill -9 `ps -ef | grep "mongo" | grep -v grep | awk '{print $2}'`
    brew install mongodb
    if [ $MONGODB_AT_START -eq 1 ]; then
        ln -sfv $HOMEBREW_BASEPATH/opt/mongodb/*.plist ~/Library/LaunchAgents
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
    fi
}

redisHandler() {
    sudo kill -9 `ps -ef | grep "redis" | grep -v grep | awk '{print $2}'`
    brew install redis
    if [ $REDIS_AT_START -eq 1 ]; then
        ln -sfv $HOMEBREW_BASEPATH/opt/redis/*.plist ~/Library/LaunchAgents
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
    fi
}

memcachedHandler() {
    sudo kill -9 `ps -ef | grep "memcache" | grep -v grep | awk '{print $2}'`
    brew install memcached libmemcached
}

phpHandler() {
    PHP_INSTALL_ARGS=""
    PHP_DEFAULT_VERSION=`echo $PHP_DEFAULT_VERSION | sed -e 's/\.//g'`
    [ $MYSQL -eq 1 ] && PHP_INSTALL_ARGS="$PHP_INSTALL_ARGS --with-mysql"
    [ $POSTGRESQL -eq 1 ] && PHP_INSTALL_ARGS="$PHP_INSTALL_ARGS --with-pgsql"

    brew unlink php$PHP_DEFAULT_VERSION

    for VERSION in $PHP_VERSIONS_TO_INSTALL
    do
        VERSION=`echo $VERSION | sed -e 's/\.//g'`
        brew install php$VERSION$PHP_INSTALL_ARGS
        brew link php$VERSION

        MODULES=$PHP_MODULES_TO_INSTALL
        [ "$VERSION" == "55" ] && MODULES=`echo $MODULES | sed -e 's/apc//g'`
        for MODULE in $MODULES
        do
            brew install php$VERSION-$MODULE
        done

        brew unlink php$VERSION

        if ! grep -q -m 1 \
            "josegonzalez/php/php$VERSION" $DEV_PROFILE_FILEPATH; then
                if [ "$VERSION" == "$PHP_DEFAULT_VERSION" ]; then
                    echo "export PATH=\"$(brew --prefix josegonzalez/php/php$VERSION)/bin:\$PATH\"" \
                        >> $DEV_PROFILE_FILEPATH
                else
                    echo "# export PATH=\"$(brew --prefix josegonzalez/php/php$VERSION)/bin:\$PATH\"" \
                        >> $DEV_PROFILE_FILEPATH
                fi
        fi
    done

    brew link php$PHP_DEFAULT_VERSION
}

phpConfigHandler() {
    for PHP_VERSION in `ls $HOMEBREW_BASEPATH/etc/php`
    do
        PHPINI_PATH="$HOMEBREW_BASEPATH/etc/php/$PHP_VERSION/php.ini"
        sed -i "" -e "s/^;\(date\.timezone\) =\s*$/\1 = $PHP_DATE_TIMEZONE/g" \
            $PHPINI_PATH
        sed -i "" -e "s/^\(memory_limit\) = .*$/\1 = $PHP_MEMORY_LIMIT/g" \
            $PHPINI_PATH
        sed -i "" -e "s/^\(post_max_size\) = .*$/\1 = $PHP_POST_MAX_SIZE/g" \
            $PHPINI_PATH
        sed -i "" -e "s/^\(upload_max_filesize\) = .*$/\1 = $PHP_UPLOAD_MAX_FILESIZE/g" \
            $PHPINI_PATH
        sed -i "" -e "s/^\(max_execution_time\) = .*$/\1 = $PHP_MAX_EXECUTION_TIME/g" \
            $PHPINI_PATH
        sed -i "" -e "s/^\(max_input_time\) = .*$/\1 = $PHP_MAX_INPUT_TIME/g" \
            $PHPINI_PATH
        if ! grep -q -m 1 "xdebug.max_nesting_level" $PHPINI_PATH; then
            echo -e "\n[xdebug]\nxdebug.max_nesting_level = $PHP_XDEBUG_MAX_NESTING_LEVEL\n" \
                >> $PHPINI_PATH
        fi
    done
}

phpApacheConfigHandler() {
    for PHP_LIB in `find "$HOMEBREW_BASEPATH/Cellar" -name "libphp5.so"`
    do
        PHP_LIB_VERSION=`echo $PHP_LIB | awk 'BEGIN{FS="/"} {print $6}' \
            | awk 'BEGIN{FS="."} {print $1"."$2}'`
        if ! grep -q -m 1 \
            "LoadModule php5_module $PHP_LIB" $APACHE_CONF_FILEPATH; then
                if [ "$PHP_LIB_VERSION" == "$PHP_DEFAULT_VERSION" ]; then
                    sudo bash -c "echo 'LoadModule php5_module $PHP_LIB' >> $APACHE_CONF_FILEPATH"
                else
                    sudo bash -c "echo '# LoadModule php5_module $PHP_LIB' >> $APACHE_CONF_FILEPATH"
                fi
        fi
    done
    if ! grep -q -m 1 \
        "# LOCFL" $APACHE_CONF_FILEPATH; then
            sudo sed -i "" -e "s/^Include \/private\/etc\/apache2\/other\/\*.conf$//g" $APACHE_CONF_FILEPATH
            sudo bash -c \
                "echo -e '# LOCFL\nInclude /private/etc/apache2/other/*.conf' >> $APACHE_CONF_FILEPATH"
    fi

    [ -f ~/Sites/vhosts/phpinfo.php ] || echo "<?php echo phpinfo; ?>" > ~/Sites/vhosts/phpinfo.php

    sudo apachectl restart
}

phpComposerHandler() {
    brew install composer
}

elasticSearchHandler() {
    sudo kill -9 `ps -ef | grep "elastic" | grep -v grep | awk '{print $2}'`
    brew install elasticsearch
    if [ $ELASTICSEARCH_AT_START -eq 1 ]; then
        ln -sfv $HOMEBREW_BASEPATH/opt/elasticsearch/*.plist ~/Library/LaunchAgents
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.elasticsearch.plist
    fi
}

rabbitmqHandler() {
    sudo kill -9 `ps -ef | grep "rabbitmq" | grep -v grep | awk '{print $2}'`
    brew install rabbitmq
    if [ $RABBITMQ_AT_START -eq 1 ]; then
        ln -sfv $HOMEBREW_BASEPATH/opt/rabbitmq/*.plist ~/Library/LaunchAgents
        launchctl load ~/Library/LaunchAgents/homebrew.mxcl.rabbitmq.plist
    fi
}

nodeNpmHandler() {
    sudo kill -9 `ps -ef | grep "node\|npm" | grep -v grep | awk '{print $2}'`
    brew install node
}

meteorHandler() {
    curl https://install.meteor.com | /bin/sh
    if [ $NODE_NPM -eq 1 ]; then
        npm install -g meteorite
    fi
}

npmPackagesHandler() {
    for NPM_PACKAGE in $NPM_PACKAGES_TO_INSTALL
    do
        npm -g install $NPM_PACKAGE
    done
}

gemPackagesHandler() {
    for GEM in $GEMS_TO_INSTALL
    do
        sudo gem install $GEM
    done
}

osxPackagesHandler() {
    brew tap phinze/homebrew-cask
    brew install brew-cask
    for OSX_PACKAGE in $OSX_PACKAGES_TO_INSTALL
    do
        brew cask install $OSX_PACKAGE
    done
    brew cask install alfred
    brew cask linkapps
    brew cask alfred link
}

homebrewFinalization() {
    brew cleanup
}

### PROCESS ##################################################################################

HOMEBREW_BASEPATH=$(brew --prefix)

homebrewPreparation

echo -e "\n\033[33m✔\033[33m Preparing and installing useful packages...\033[0m\n"
environmentPreparation

echo -e "\n\033[33m✔\033[33m Installing CLI packages...\033[0m\n"
cliPackagesHandler

if [ $GIT -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring Git...\033[0m\n"
    gitHandler
fi

if [ $ZSH -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring ZSH...\033[0m\n"
    zshHandler
fi

if [ $APACHE_CONFIG -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring Apache...\033[0m\n"
    apacheConfigHandler
fi

if [ $MYSQL -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring MySQL...\033[0m\n"
    mysqlHandler
fi

if [ $POSTGRESQL -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring PostgreSQL...\033[0m\n"
    postgreSqlHandler
fi

if [ $MONGODB -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring MongoDB...\033[0m\n"
    mongodbHandler
fi

if [ $REDIS -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring Redis...\033[0m\n"
    redisHandler
fi

if [ $MEMCACHED -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing Memcached dependencies...\033[0m\n"
    memcachedHandler
fi

if [ $PHP -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing PHP...\033[0m\n"
    phpHandler

    if [ $PHP_CUSTOMIZE_PHPINI -eq 1 ]; then
        echo -e "\n\033[33m✔\033[33m Configuring PHP...\033[0m\n"
        phpConfigHandler
    fi

    if [ $APACHE_CONFIG -eq 1 ]; then
        echo -e "\n\033[33m✔\033[33m Configuring Apache for PHP...\033[0m\n"
        phpApacheConfigHandler
    fi

    if [ $COMPOSER -eq 1 ]; then
        echo -e "\n\033[33m✔\033[33m Adding PHP Composer...\033[0m\n"
        phpComposerHandler
    fi
fi

if [ $ELASTICSEARCH -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring ElasticSearch...\033[0m\n"
    elasticSearchHandler
fi

if [ $RABBITMQ -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring RabbitMQ...\033[0m\n"
    rabbitmqHandler
fi

if [ $NODE_NPM -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring Node and NPM...\033[0m\n"
    nodeNpmHandler
fi

if [ $METEOR -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing and configuring Meteor(ite)...\033[0m\n"
    meteorHandler
fi

echo -e "\n\033[33m✔\033[33m Installing NPM packages...\033[0m\n"
npmPackagesHandler

echo -e "\n\033[33m✔\033[33m Installing GEM packages...\033[0m\n"
gemPackagesHandler

if [ $OSX_PACKAGES -eq 1 ]; then
    echo -e "\n\033[33m✔\033[33m Installing OSX packages, via Cask...\033[0m\n"
    osxPackagesHandler
fi

homebrewFinalization
