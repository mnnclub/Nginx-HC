*****Nginx 1.16 + health check (= upstream check module )*****

1. Dependency : nginx 1.16 + openssl 1.1.1

- upstream check module's last version developed with in nginx 1.16
- rocky, alma linux 8's openssl version is 1.1.1x that acceptable

2. Configure
   2.1 Docker's base image is almalinux 8.9: minimal
   2.2 git clone source nginx 1.16 + modules
