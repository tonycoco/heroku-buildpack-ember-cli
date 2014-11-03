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

#### Nginx Workers

Set the number of workers for Nginx (Default: `4`):

    heroku config:set NGINX_WORKERS=4

#### API Proxy

Set an API proxy URL:

    heroku config:set API_URL=http://api.example.com/

Set your API's prefix path (Default: `/api/`):

    heroku config:set API_PREFIX_PATH=/api/

*Note that the trailing slashes are important. For more information about API proxies and avoiding CORS, [read this](http://oskarhane.com/avoid-cors-with-nginx-proxy_pass).*
**This step requires that you specify a matching `namespace` on your Ember Data adapter. For example, you could use `app/adapters/application.js` as follows:**
```javascript
import DS from "ember-data";

export default DS.RESTAdapter.extend({
  namespace: 'api'
});

```

#### Authentication

Have a staging server? Want to protect it with authentication? When `BASIC_AUTH_USER` and `BASIC_AUTH_PASSWORD` are set basic authentication will be activated:

    heroku config:set BASIC_AUTH_USER=EXAMPLE_USER
    heroku config:set BASIC_AUTH_PASSWORD=EXAMPLE_PASSWORD

*Be sure to use `https` when you set this up for added security.*

#### Force HTTPS

For most Ember applications that make any kind of authenticated requests (sending an auth token with a request for example), HTTPS should be used. Enable this feature in nginx by setting `FORCE_HTTPS`.

    heroku config:set FORCE_HTTPS=true

### Custom

Need to make a custom nginx configuration change? No problem. In your Ember CLI application, add a `config/nginx.conf.erb` file. You can copy the existing configuration file in this repo and make your changes to it.

### Caching

The Ember CLI buildpack caches your npm and bower dependencies be default. This is similar to the [Heroku Buildpack for Node.js](https://github.com/heroku/heroku-buildpack-nodejs). This makes typical deployments much faster. Note that dependencies like [`components/ember#canary`](http://www.ember-cli.com/#using-canary-build-instead-of-release) will not be updated on each deploy.

To [purge the cache](https://github.com/heroku/heroku-repo#purge_cache) and reinstall all dependencies, run:

```shell
heroku plugins:install https://github.com/heroku/heroku-repo.git
heroku repo:purge_cache -a APPNAME
```
