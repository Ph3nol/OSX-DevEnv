# OSX Development Environment

## Work in progress

This is not a yet-usables script.
But of course, feel free to test it and contribute! :)

## Installation

First, you must download config example and edit it for your needs:

```
curl -sS https://raw.github.com/Ph3nol/OSX-DevEnv/master/.config \
    -o ~/.osx-dev.config.install
vim ~/.osx-dev.config.install
```

Save your updates and run the script:

```
curl -sS https://raw.github.com/Ph3nol/OSX-DevEnv/master/install.sh | sh
```

## Multiple versions of PHP

You can easily switch CLI/Apache PHP version by using this alias:

```
swphp 5.3
swphp 5.4
swphp 5.5
```

## Aliases

Some aliases have been added to bring fun into your dev life! ;)

* `x` to exit
* `..`, `..`, `..`, (etc.) to browse back your folders
* `mcflush` to purge your local Memcached data (11211 default port)
* `vflush` to flush local Varnish cache (from global URL ban)
* `phpinfo` to open fast phpinfo() into your default browser
* `pma` to open fast PHPMyAdmin instance into your default browser
* `subl` to easy and fast access to Sublime Text 2 (if installed)
* `reload` to reload your shell

## Included tools/features

* CLI packages
* ZSH
* Git configuration
* Native OSX Apache configuration
* PHP multiversions (+ PEAR/Pecl packages, PHPMyAdmin and Composer)
* MySQL
* PostgreSQL
* MongoDB
* Redis
* Memcached
* ElasticSearch
* RabbitMQ
* Node/NPM
* Meteor
* Gem packages easy-install
* NPM packages easy-install
* OSX packages easy-install (through Brew Cask)
* Some dotfiles (aliases, pathes and others!)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Ph3nol/osx-devenv/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

