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

#### Authentication

Have a staging server? Want to protect it with authentication? When `BASIC_AUTH_USER` and `BASIC_AUTH_PASSWORD` are set basic authentication will be activated:

    heroku config:set BASIC_AUTH_USER=EXAMPLE_USER
    heroku config:set BASIC_AUTH_PASSWORD=EXAMPLE_PASSWORD

*Be sure to use `https` when you set this up for added security.*

#### Force HTTPS

For most Ember applications that make any kind of authenticated requests (sending an auth token with a request for example), HTTPS should be used. Enable this feature in nginx by setting `FORCE_HTTPS`.

    heroku config:set FORCE_HTTPS=true

#### Compass

If you want to compile your compass assets as part of the build process, first create a `compass.sh` file in the `bin` directory, then add this code to it:

    export GEM_HOME=$build_dir/.gem/ruby/1.9.1
    PATH="$GEM_HOME/bin:$PATH"
    if test -d $cache_dir/ruby/.gem; then
      status "Restoring ruby gems directory from cache"
      cp -r $cache_dir/ruby/.gem $build_dir
      HOME=$build_dir gem update compass --user-install --no-rdoc --no-ri
    else
      HOME=$build_dir gem install compass --user-install --no-rdoc --no-ri
    fi

    # cache ruby gems compass
    rm -rf $cache_dir/ruby
    mkdir -p $cache_dir/ruby

    # If app has a gems directory, cache it.
    if test -d $build_dir/.gem; then
      status "Caching ruby gems directory for future builds"
      cp -r $build_dir/.gem $cache_dir/ruby
    fi

#### Prerender.io

[Prerender.io](https://prerender.io) allows your application to be crawled by search engines.

Set the service's host and token:

    heroku config:set PRERENDER_HOST=service.prerender.io
    heroku config:set PRERENDER_TOKEN=<your-prerender-token>

Sign up for the hosted [Prerender.io](https://prerender.io) service or host it yourself. See the [project's repo](https://github.com/prerender/prerender) for more information.

#### Private Repos

Got private NPM or Bower GitHub repos? Configure a `GIT_SSH_KEY` so that Heroku can access these packages:

    heroku config:set GIT_SSH_KEY=<base64-encoded-private-key>

If present, the buildpack expects the base64 encoded contents of a private key whose public key counterpart has been registered with GitHub on an account with access to any private repositories needed by the application. Prior to executing `npm install` and `bower install` it decodes the contents into a file, launches ssh-agent and registers that keyfile. Once NPM install is finished, it cleans up the environment and file system of the key contents.

Private NPM dependency URLs must be in the form of `git+ssh://git@github.com:[user]/[repo].git`. Private Bower dependency URLs must be in the form of `git@github.com:[user]/[repo].git`. Either NPM or Bower URLs may have a trailing `#semver`.

### Custom Nginx

Need to make a custom nginx configuration change? No problem. In your Ember CLI application, add a `config/nginx.conf.erb` file. You can copy the existing configuration file in this repo and make your changes to it.

### Caching

The Ember CLI buildpack caches your npm and bower dependencies be default. This is similar to the [Heroku Buildpack for Node.js](https://github.com/heroku/heroku-buildpack-nodejs). This makes typical deployments much faster. Note that dependencies like [`components/ember#canary`](http://www.ember-cli.com/#using-canary-build-instead-of-release) will not be updated on each deploy.

To [purge the cache](https://github.com/heroku/heroku-repo#purge_cache) and reinstall all dependencies, run:

```shell
heroku plugins:install https://github.com/heroku/heroku-repo.git
heroku repo:purge_cache -a APPNAME
```
