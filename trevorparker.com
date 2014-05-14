upstream docker_trevorparker_com {
    ip_hash;

    server 127.0.0.1:4001;
    server 127.0.0.1:4002;
    server 127.0.0.1:4003;
}

server {
    server_name trevorparker.com;

    listen *:80;
    listen *:443 ssl;
    listen [::]:80 ipv6only=on;
    listen [::]:443 ssl ipv6only=on;

    server_tokens off;

    access_log /var/log/nginx/trevorparker.com-access.log;
    error_log  /var/log/nginx/trevorparker.com-error.log;

    ssl_certificate     /etc/ssl/localcerts/trevorparker.com.chained.pem;
    ssl_certificate_key /etc/ssl/localcerts/trevorparker.com.key;

    ssl_protocols             SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout       5m;
    ssl_session_cache         builtin:1000 shared:SSL:10m;
    ssl_ciphers               ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:RC4-SHA;

    add_header Strict-Transport-Security max-age=31536000;

    charset        utf-8;
    source_charset utf-8;

    return 301 https://www.trevorparker.com$request_uri;
}

server {
    server_name www.trevorparker.com;
    listen *:80;
    listen [::]:80;

    server_tokens off;

    access_log /var/log/nginx/trevorparker.com-access.log;
    error_log  /var/log/nginx/trevorparker.com-error.log;

    return 301 https://www.trevorparker.com$request_uri;
}

server {
    server_name www.trevorparker.com;
    listen *:443;
    listen [::]:443 ssl;

    server_tokens off;

    access_log /var/log/nginx/trevorparker.com-access.log;
    error_log  /var/log/nginx/trevorparker.com-error.log;

    ssl_certificate     /etc/ssl/localcerts/trevorparker.com.chained.pem;
    ssl_certificate_key /etc/ssl/localcerts/trevorparker.com.key;

    ssl_protocols             SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers               ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-RC4-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:RC4-SHA:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!DSS:!PKS;
    ssl_session_timeout       5m;
    ssl_session_cache         builtin:1000 shared:SSL:10m;

    add_header Strict-Transport-Security max-age=31536000;

    charset        utf-8;
    source_charset utf-8;

    location / {
        rewrite                /\d\d\d\d/\d\d/(.*)$ https://www.trevorparker.com/$1 permanent;
        error_page             404 /error/404.html;
        proxy_pass             http://docker_trevorparker_com;
        proxy_set_header       X-Real-IP $remote_addr;
        proxy_set_header       Host $host;
        proxy_redirect         http://$host/ https://$host/;
        proxy_intercept_errors on;
    }

    location /assets/img/ {
        error_page             404 /error/404.html;
        proxy_pass             http://docker_trevorparker_com;
        proxy_set_header       X-Real-IP $remote_addr;
        proxy_set_header       Host $host;
        proxy_redirect         http://$host/ https://$host/;
        proxy_intercept_errors on;

        valid_referers none blocked trevorparker.com *.trevorparker.com ~\.google\. ~\.yahoo\. ~\.bing\. ~\.facebook\. ~\.fbcdn\.;
        if ($invalid_referer) {
            return 403;
        }
    }
}
