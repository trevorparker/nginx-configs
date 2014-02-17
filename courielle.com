server {
    server_name courielle.com;

    listen *:80;
    listen [2600:3c03::1d:4203]:80;

    server_tokens off;

    access_log /var/log/nginx/courielle.com-access.log;
    error_log  /var/log/nginx/courielle.com-error.log;

    charset        utf-8;
    source_charset utf-8;

    return 301 http://www.courielle.com$request_uri;
}

server {
    server_name www.courielle.com;

    listen 80;
    listen [2600:3c03::1d:4203]:80;

    server_tokens off;

    access_log /var/log/nginx/courielle.com-access.log;
    error_log  /var/log/nginx/courielle.com-error.log;

    charset        utf-8;
    source_charset utf-8;

    root /home/cdmacca/jail/web/;

    location / {
        index index.html index.htm;
        ssi on;
    }
}

server {
    server_name test.courielle.com;

    listen 80;
    listen [2600:3c03::1d:4203]:80;

    server_tokens off;

    access_log /var/log/nginx/test.courielle.com-access.log;
    error_log  /var/log/nginx/test.courielle.com-error.log;

    charset        utf-8;
    source_charset utf-8;

    root /home/cdmacca/jail/test/;

    location / {
        index index.html index.htm;
        ssi on;
    }
}
