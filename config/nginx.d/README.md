# Extending NGINX configuration

You can add snippets of NGINX configuration in this directory by creating files whose filenames end in `.conf`.  These files will be included in the `server` section of the configuration, above the buildpack customisations.

For example, if you need to use a reverse proxy to include a special `/admin` section of your site:

```
location /admin {
  proxy_pass https://my-app-admin.herokuapp.com/;
  proxy_set_header Real-IP $remote_addr;
  proxy_set_header Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header NginX-Proxy true;
  proxy_ssl_session_reuse off;
  proxy_redirect off;
}
```
