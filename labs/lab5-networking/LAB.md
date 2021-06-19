# Lab 5. Exposing your application with kubernetes networking

## 1. Exposing workloads using `Services`

Let's start of by creating anaother application for this lab.
First lets create an index.html file in a lab5 folder with the following content.

index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      html {
        height: 100%;
      }
      .flex-container {
        display: flex;
        height: 80%;
        justify-content: center;
        align-items: center;
        background-color: APP_COLOR;
      }

      .flex-container > div {
        width: 100%;
        margin: 10px;
        text-align: center;
        line-height: 150px;
        font-size: 60px;
        color: white;
      }
    </style>
  </head>
  <body class="flex-container">
    <div>APP_MESSAGE</div>
  </body>
</html>
```

Next let's add a script file entrypoint.sh that will overwrite `APP_COLOR` and `APP_MESSAGE` in the index.html file values with environment variables with the same name.

entrypoint.sh

```sh
#!/bin/sh
if [ "$APP_COLOR" == "Blue" ];
then
    sed -i "s/APP_COLOR/$APP_COLOR/g" /usr/share/nginx/html/index.html
elif [ "$APP_COLOR" == "Red" ];
then
    sed -i "s/APP_COLOR/$APP_COLOR/g" /usr/share/nginx/html/index.html
elif [ "$APP_COLOR" == "Purple" ];
then
    sed -i "s/APP_COLOR/$APP_COLOR/g" /usr/share/nginx/html/index.html
elif [ "$APP_COLOR" == "Orange" ];
then
    sed -i "s/APP_COLOR/$APP_COLOR/g" /usr/share/nginx/html/index.html
else
    sed -i "s/APP_COLOR/Green/g" /usr/share/nginx/html/index.html
fi

if test -z "$APP_MESSAGE"; then
      sed -i "s/APP_MESSAGE/Hello There!/g" /usr/share/nginx/html/index.html
else
    sed -i "s/APP_MESSAGE/$APP_MESSAGE/g" /usr/share/nginx/html/index.html
fi
```

Next let's add a nginx configuration file default.conf.

default.conf
```text
server {

  listen 80;

  sendfile on;

  default_type application/octet-stream;

  gzip on;
  gzip_http_version 1.1;
  gzip_disable      "MSIE [1-6]\.";
  gzip_min_length   256;
  gzip_vary         on;
  gzip_proxied      expired no-cache no-store private auth;
  gzip_types        text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript;
  gzip_comp_level   9;

  location / {
    alias /usr/share/nginx/html/;
    try_files $uri $uri/ /index.html =404;
    expires -1;
  }
}
```

And finally let's add a Dockerfile.

Dockerfile

```text
FROM nginx:stable-alpine
COPY default.conf /etc/nginx/conf.d/
COPY index.html /usr/share/nginx/html
COPY entrypoint.sh /docker-entrypoint.d
```

We can now build and test our application by running the following commands.

```powershell
az acr build -t nginxsample:v1 -r $ACR_NAME . 
docker run --rm -it -p 8082:80 "$($ACR_NAME).azurecr.io/nginxsample:v1" 
docker run --rm -it -p 8082:80  -e APP_COLOR=Blue -e APP_MESSAGE='Great Times!'  "$($ACR_NAME).azurecr.io/nginxsample:v1" 
docker run --rm -it -p 8082:80  -e APP_COLOR=Red -e APP_MESSAGE='Hey Ho Let'\''s Go!'   "$($ACR_NAME).azurecr.io/nginxsample:v1" 

```







## 2. Exposing workloads with Application Gateway using `Ingresses`




[:arrow_backward: previous](../lab4-configuration/LAB.md)  [next :arrow_forward:](../lab6-volumes/LAB.md)