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