Note: A recent change to the buildpack has made caching much more aggressive. If you are having trouble deploying run...

    $ heroku config:set REBUILD_ALL=true
    $ heroku plugins:install https://github.com/heroku/heroku-repo.git
    $ heroku repo:purge_cache -a APPNAME

Be sure to replace `APPNAME` with your app's name. Now, push your repo up. Once that build is complete, your dependencies are rebuilt and cached. Now, unset the var...

    $ heroku config:unset REBUILD_ALL

Future deploys should now work much faster!

# Heroku Buildpack for Ember CLI Applications

This buildpack will work out of the box with Ember CLI generated applications. It installs Node, Nginx and generates a production build with the Ember CLI.

## Usage

Creating a new Heroku instance from an Ember CLI application's parent directory:

    $ heroku create --buildpack https://github.com/tonycoco/heroku-buildpack-ember-cli.git

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom buildpack
    ...

Or, use the Heroku Deploy button:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Configuration

You can set a few different environment variables to turn on features in this buildpack.

### Nginx Workers

Set the number of workers for Nginx (Default: `4`):

    $ heroku config:set NGINX_WORKERS=4

This will depend on your Heroku instance size and the amount of dynos.

### API Proxy

Set an API proxy URL:

    $ heroku config:set API_URL=http://api.example.com/

Set your API's prefix path (Default: `/api/`):

    $ heroku config:set API_PREFIX_PATH=/api/

*Trailing slashes are important. For more information about API proxies and avoiding CORS, [read this](http://oskarhane.com/avoid-cors-with-nginx-proxy_pass).*

### Authentication

Setting `BASIC_AUTH_USER` and `BASIC_AUTH_PASSWORD` in your Heroku application will activate basic authentication:

    $ heroku config:set BASIC_AUTH_USER=EXAMPLE_USER
    $ heroku config:set BASIC_AUTH_PASSWORD=EXAMPLE_PASSWORD

*Be sure to use HTTPS for added security.*

### Force HTTPS/SSL

For most Ember applications that make any kind of authenticated requests HTTPS should be used. It supports the headers `X-Forwarded-Proto` ([used by Heroku](https://devcenter.heroku.com/articles/http-routing#heroku-headers)) and `CF-Visitor` ([used by CloudFlare](https://support.cloudflare.com/hc/en-us/articles/200170536-How-do-I-redirect-HTTPS-traffic-with-Flexible-SSL-and-Apache-)). Enable this feature in Nginx by setting `FORCE_HTTPS`:

    $ heroku config:set FORCE_HTTPS=true

### LetsEncrypt support

Using `heroku config:set ACME_CHALLENGE=<challenge-phrase>` allows the app to respond correctly to the call from a manual `certbot` command that is used to generate a LetsEncrypt SSL certificate.

Follow these steps to get your free SSL certificate installed. (Assumes you have [SNI-SSL](https://devcenter.heroku.com/articles/ssl-beta) installed on your app.)

    $ sudo certbot certonly --email=<your-email-address> --manual -d <your-domain-name>
    $ heroku config:set ACME_CHALLENGE='<challenge phrase returned from the above command>'
    # copy fullchain.pem privkey.pem locally from the path certbot put them
    $ heroku _certs:update fullchain.pem privkey.pem
    $ heroku config:unset ACME_CHALLENGE

### Prerender.io

[Prerender.io](https://prerender.io) allows your application to be crawled by search engines.

Set the service's host and token:

    $ heroku config:set PRERENDER_HOST=service.prerender.io
    $ heroku config:set PRERENDER_TOKEN=<your-prerender-token>

*Sign up for the hosted [Prerender.io](https://prerender.io) service or host it yourself. See the [project's repo](https://github.com/prerender/prerender) for more information.*

### Naked Domain Redirection

Visitors can be redirected from your "naked domain" (`example.com`) to `www.example.com`. Set your naked domain:

    $ heroku config:set NAKED_DOMAIN=example.com

*This uses a HTTP 301 redirect to forward the request. All parameters are preserved.*

### Private Repositories

Configure a `GIT_SSH_KEY` to allow Heroku access to private repositories:

    $ heroku config:set GIT_SSH_KEY=<base64-encoded-private-key>

If present, the buildpack expects the base64 encoded contents of a private key whose public key counterpart has been registered with GitHub on an account with access to any private repositories needed by the application. Prior to executing `npm install` and `bower install` it decodes the contents into a file, launches ssh-agent and registers that keyfile. Once NPM install is finished, it cleans up the environment and file system of the key contents.

Private NPM dependency URLs must be in the form of `git+ssh://git@github.com:[user]/[repo].git`. Private Bower dependency URLs must be in the form of `git@github.com:[user]/[repo].git`. Either NPM or Bower URLs may have a trailing `#semver`.

### Environment

Choose the environment you want to build by setting:

    $ heroku config:set EMBER_ENV=production

### Before and After Hooks

Have the buildpack run your own scripts before and after the `ember build` by creating a `hooks/before_hook.sh` or `hooks/after_hook.sh` file in your Ember CLI application:

    $ mkdir -p hooks

For a before build hook:

    $ touch hooks/before_hook.sh
    $ chmod +x hooks/before_hook.sh

For an after build hook:

    $ touch hooks/after_hook.sh
    $ chmod +x hooks/after_hook.sh

*See below for examples.*

#### Example Before Hook: Compass

[Compass](http://compass-style.org) can be installed using the before build hook. Create `hooks/before_hook.sh` and add the following script:

```bash
#!/usr/bin/env bash

export GEM_HOME=$build_dir/.gem/ruby/2.2.0
export PATH=$GEM_HOME/bin:$PATH

if test -d $cache_dir/ruby/.gem; then
  status "Restoring ruby gems directory from cache"
  cp -r $cache_dir/ruby/.gem $build_dir
  HOME=$build_dir gem update compass --user-install --no-rdoc --no-ri
else
  HOME=$build_dir gem install compass --user-install --no-rdoc --no-ri
fi

rm -rf $cache_dir/ruby
mkdir -p $cache_dir/ruby

if test -d $build_dir/.gem; then
  status "Caching ruby gems directory for future builds"
  cp -r $build_dir/.gem $cache_dir/ruby
fi
```

### Force Rebuilds

Sometimes it is necessary to rebuild NPM modules or Bower dependencies from scratch.  This can become necessary when updating Ember or EmberCLI midway through a project and cleaning the Bower and NPM caches doesn't always refresh the cache in the Dyno during the next deployment.  In those cases, here is a simple and clean way to force a rebuild.

To force a rebuild of NPM modules *and* Bower dependencies:

    heroku config:set REBUILD_ALL=true
    git commit -am 'rebuild' --allow-empty
    git push heroku master
    heroku config:unset REBUILD_ALL

To force a rebuild of just the NPM modules:

    heroku config:set REBUILD_NODE_PACKAGES=true
    git commit -am 'rebuild' --allow-empty
    git push heroku master
    heroku config:unset REBUILD_NODE_PACKAGES

To force a rebuild of Bower dependencies:

    heroku config:set REBUILD_BOWER_PACKAGES=true
    git commit -am 'rebuild' --allow-empty
    git push heroku master
    heroku config:unset REBUILD_BOWER_PACKAGES

### Custom Nginx

You can install a custom build of Nginx by setting the $NGINX_URL:

    $ heroku config:set NGINX_URL=<the url to your custom build of nginx>

Without this set, the version of Nginx installed will be 1.6.0.

### Custom Nginx config

In your Ember CLI application, add a `config/nginx.conf.erb` file and add your own Nginx configuration.

*You should copy the existing configuration file in this repo and make changes to it for best results.*

### Caching

The Ember CLI buildpack caches your NPM and Bower dependencies by default. This is similar to the [Heroku Buildpack for Node.js](https://github.com/heroku/heroku-buildpack-nodejs). This makes typical deployments much faster. Note that dependencies like [`components/ember#canary`](http://www.ember-cli.com/#using-canary-build-instead-of-release) will not be updated on each deploy.

To [purge the cache](https://github.com/heroku/heroku-repo#purge_cache) and reinstall all dependencies, run:

    $ heroku plugins:install https://github.com/heroku/heroku-repo.git
    $ heroku repo:purge_cache -a APPNAME

### IP Whitelist

Setting `IP_WHITELIST` in your Herkou application to a comma delimited list of IP addresses or CIDR blocks will restrict access to your application to only those values.

    $ heroku config:set IP_WHITELIST=192.168.0.0/24,192.168.1.42

## Troubleshooting

Clean your project's dependencies:

    $ npm cache clear
    $ bower cache clean
    $ rm -rf node_modules bower_components
    $ npm install --no-optional
    $ bower install

Be sure to save any Bower or NPM resolutions. Now, let's build your Ember CLI application locally:

    $ ember build

Check your `git status` and see if that process has made any changes to your application's code. Now, try your Heroku deployment again.

### NPM not installing anything in production

Heroku will run npm scripts in `production` mode if your `NODE_ENV` is set to `production`. Since all Ember dependencies are in devDependencies, nothing will install. To fix this, run:

    $ heroku config:set NPM_CONFIG_PRODUCTION=false

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

A special thanks to everyone who maintains and helps out on the project!

- Aaron Chambers
- Aaron Ortbals
- Aaron Renner
- Adriaan
- Adriaan van Rossum
- Bill Curtis
- Brett Chalupa
- Chris Santero
- Donal Byrne
- GabKlein
- Gabriel Klein
- John Griffin
- Jonas Brusman
- Jonathan Johnson
- Jonathan Zempel
- Jordan Morano
- Juan Pablo Pinilla Ossa
- Kori Roys
- Matt McGinnis
- Mayank Patel
- Optimal Cadence
- Peter Brown
- Rob Guilfoyle
- Ryan LeFevre
- Tony Coconate
- harianus
- sbl

_Generated with: `git log --format='%aN' | sort -u`._
