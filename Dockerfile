# 기반이 될 이미지를 가져옵니다. 여기서는 linux-minimal을 사용합니다.
FROM almalinux:8.9

# 작업 디렉토리를 설정합니다.
WORKDIR /usr/src

# nginx를 컴파일하고 설치합니다.
RUN /usr/bin/yum -y groupinstall "Development Tools" --setopt=group_package_types=mandatory,default,optional && \
    /usr/bin/dnf -y install pcre-devel libxslt-devel gd-devel openssl-devel wget git


RUN /usr/bin/git clone https://github.com/mnnclub/Nginx-HC.git && \
    cd Nginx-HC/nginx-1.16.1_HC && \
    ./configure \
    --add-module=./nginx_upstream_check_module \
    --with-http_xslt_module=dynamic --with-http_realip_module \
    --with-http_stub_status_module --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic --with-http_xslt_module=dynamic \
    --prefix=/usr/local/nginx \
    --with-http_dav_module \
    --with-stream \
    --with-openssl=./openssl-1.1.1t \
    --with-http_addition_module \
    --with-http_dav_module \
    --with-http_gzip_static_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_sub_module \
    --with-http_xslt_module \
    --with-http_ssl_module \
    --with-http_v2_module && \
    make && \
    make install && \
    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx && \
    nginx -V

COPY conf /usr/local/nginx/conf

# make self signed certificate : localhost.localdomain
WORKDIR /usr/local/nginx
RUN openssl req -x509 -nodes -new -sha256 -days 3650 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=KR/CN=TheRootCA" && \
    openssl x509 -outform pem -in RootCA.pem -out RootCA.crt && \
    openssl req -new -nodes -newkey rsa:2048 -keyout localhost.localdomain.key -out localhost.localdomain.csr -subj "/C=KR/ST=LocalStreet/L=Seoul/O=LocalCompany/CN=localhost.localdomain" && \
    echo 'authorityKeyIdentifier=keyid,issuer \
    basicConstraints=CA:FALSE \
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment \
    subjectAltName = @alt_names \
    [alt_names] \
    DNS.1 = localhost \
    DNS.2 = localhost.localdomain \
    DNS.3 = 10.254.254.1 \
    DNS.4 = 10.254.254.2 \
    DNS.5 = 127.0.0.1' > localhost_ext.txt && \
    openssl x509 -req -sha256 -days 3650 -in localhost.localdomain.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -extfile domains_ext.txt -out localhost.localdomain.crt


COPY nginx116.service /etc/systemd/system/nginx116.service
RUN chmod 755 /etc/systemd/system/nginx116.service && \
    systemctl daemon-reload

# 컨테이너가 80, 443 포트로 들어오는 요청을 처리할 수 있도록 열어줍니다.
EXPOSE 80
EXPOSE 443

# nginx를 실행합니다.
#CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
CMD ["systemctl start nginx116"]
