# Heroku Buildpack for Ember CLI Applications

This buildpack will work out-of-the-box with Ember CLI generated applications. It installs node, nginx and generates a production build with the Ember CLI.

## Usage

Creating a new Heroku instance from an Ember CLI application's parent directory:

    $ heroku create --buildpack https://github.com/tonycoco/heroku-buildpack-ember-cli.git

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom buildpack
    ...

## Configuration

### Variables

You can set a few different environment variables to turn on features in this buildpack.

Set the number of workers for Nginx (Default: `4`):

    heroku config:set NGINX_WORKERS=4

Set an API proxy URL:

    heroku config:set API_URL=http://api.example.com

Set your API's prefix path (Default: `/api/`):

    heroku config:set API_PREFIX_PATH=/api/

*For more information about API proxies [read this](http://oskarhane.com/avoid-cors-with-nginx-proxy_pass).*

### Custom

Need to make a custom nginx configuration change? No problem. In your Ember CLI application, add a `config/nginx.conf.erb` file. You can copy the existing configuration file in this repo and make your changes to it.
