Heroku Buildpack for Ember CLI Applications
===========================================

This buildpack will work out-of-the-box with Ember CLI generated applications. It installs node, nginx and generates a production build with the Ember CLI.

Usage
-----

Creating a new Heroku instance from an Ember CLI application's parent directory:

    $ heroku create --buildpack https://github.com/tonycoco/heroku-buildpack-ember-cli.git

    $ git push heroku master
    ...
    -----> Heroku receiving push
    -----> Fetching custom buildpack
    ...

Need to make a custom nginx configuration change? No problem. In your Ember CLI application, add a `config/nginx.conf.erb` file. You can copy the existing configuration file in this repo and make your changes to it.
