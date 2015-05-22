upstream docker_trevorparker_com {
    ip_hash;
    server 127.0.0.1:8080;
    server 127.0.0.1:8081;
    server 127.0.0.1:8082;
}

server {
    server_name trevorparker.com www.trevorparker.com;
    listen *:80;
    listen [::]:80;

    server_tokens off;

    charset        utf-8;
    source_charset utf-8;

    access_log /var/log/nginx/trevorparker.com-access.log;
    error_log  /var/log/nginx/trevorparker.com-error.log;

    return 301 https://www.trevorparker.com$request_uri;
}

server {
    server_name trevorparker.com;
    listen *:443 ssl;
    listen [::]:443 ssl;

    server_tokens off;

    charset        utf-8;
    source_charset utf-8;

    access_log /var/log/nginx/trevorparker.com-access.log;
    error_log  /var/log/nginx/trevorparker.com-error.log;

    ssl_certificate     /etc/ssl/localcerts/trevorparker.com.chained.pem;
    ssl_certificate_key /etc/ssl/localcerts/trevorparker.com.key;

    ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers               DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:kEDH+AESGCM:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
    ssl_session_timeout       5m;
    ssl_session_cache         shared:SSL:10m;
    ssh_dhparam               /etc/ssl/dhparams.pem

    add_header Strict-Transport-Security max-age=31536000;

    return 301 https://www.trevorparker.com$request_uri;
}

server {
    server_name www.trevorparker.com;
    listen *:443;
    listen [::]:443 ssl;

    server_tokens off;

    charset        utf-8;
    source_charset utf-8;

    access_log /var/log/nginx/trevorparker.com-access.log;
    error_log  /var/log/nginx/trevorparker.com-error.log;

    ssl_certificate     /etc/ssl/localcerts/trevorparker.com.chained.pem;
    ssl_certificate_key /etc/ssl/localcerts/trevorparker.com.key;

    ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers               DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:kEDH+AESGCM:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
    ssl_session_timeout       5m;
    ssl_session_cache         shared:SSL:10m;
    ssh_dhparam               /etc/ssl/dhparams.pem

    add_header Strict-Transport-Security max-age=31536000;

    location / {
        proxy_pass       http://docker_trevorparker_com;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

