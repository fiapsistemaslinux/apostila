# Lamp com Niginx: Instalação do Projeto Mediawiki

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-lab.png)


Instalação do Projeto [MediaWiki]() na plataforma Ubuntu 18.04 LTS com suporte ao Nginx usando MariaDB e PHP 7.1

---

1. Instale o pacote Nginx que será utilizado como servidor de conteúdo para o MediaWiki:

```sh
sudo apt update && sudo apt install nginx
#
sudo systemctl enable nginx.service
sudo systemctl status nginx.service
``` 

2. Instale o SGBD MariaDB:

> O Projeto MediaWiki utiliza uma base de dados relacional, neste laboratório será utilizado o MariaDB, outras opções de banco de dados para este projeto podem ser consultadas na [documentação oficial]();

```sh
sudo apt install mariadb-server mariadb-client
#
sudo systemctl enable mariadb.service
sudo systemctl status mariadb.service
```

3. O MariaDB utiliza uma instalação padrão sem senha administrativa (Ao invés de questionar o usuário sobre a senha no momento da instalação), após a instalação é utilizado um script de configuração do SGBD:

```sh
sudo mysql_secure_installation
```

Quando solicitado, responda às perguntas abaixo seguindo o guia:

```sh
Enter current password for root (enter for none): Just press the Enter
Set root password? [Y/n]: Y
New password: Enter password
Re-enter new password: Repeat password
Remove anonymous users? [Y/n]: Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n]:  Y
Reload privilege tables now? [Y/n]:  Y
```

4. Instalação do PHP 7.1 com FPM:

Este projeto é escrito na [linguagem de programação php]() sendo necessário a instalação e configuração dos módulos de php com suporte para o Nginx;

```sh
sudo apt install php7.2-fpm php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-soap php7.2-gd php7.2-xml php7.2-intl php7.2-mysql php7.2-cli php7.2-zip php7.2-curl
```

Após instalar o php 7.2, edite o arquivo **/etc/php/7.1/fpm/php.ini** conforme o padrão abaixo:

```sh
sudo vim /etc/php/7.2/fpm/php.ini
```

```sh
memory_limit = 256M
upload_max_filesize = 100M
max_execution_time = 360
cgi.fix_pathinfo = 0
date.timezone = America/SaoPaulo
```

5. Criar banco de dados MediaWiki:

Após a instalou todos dos pacotes necessários, crie um banco de dados para o Projeto:

```sh
sudo mysql -u root -p
```

Dentro do SGBD execute: 

```sh
CREATE DATABASE mediawiki;
CREATE USER 'mediawikiuser'@'localhost' IDENTIFIED BY 'fiap_123456';
GRANT ALL ON mediawiki.* TO 'mediawikiuser'@'localhost' IDENTIFIED BY 'fiap_123456' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

6. Download MediaWiki:

Execute os comandos abaixo para baixar o release mais recente do MediaWiki:

```sh
cd /tmp && wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.0.tar.gz
```

Extração dos arquivos de download para a raiz do Servidor de Conteúdo:

```sh
sudo tar -zxvf mediawiki*.tar.gz
sudo mkdir -p /var/www/html/mediawiki
sudo mv mediawiki*/* /var/www/html/mediawiki -v
#
sudo chown -R www-data:www-data /var/www/html/mediawiki/
sudo chmod -R 755 /var/www/html/mediawiki/
```

7. Configuração do Nginx:

Configure um Virtual Server para o MediaWiki:

```sh

export DOMAIN_NAMES="mediawiki.fiapdev.com wiki.fiapdev.com"

cat <<EOF | sudo tee /etc/nginx/sites-available/mediawiki
server {
    listen 80;
    listen [::]:80;
    root /var/www/html/mediawiki;
    index  index.php index.html index.htm;
    server_name  ${DOMAIN_NAMES};

     client_max_body_size 100M;

     location / {
	try_files \$uri \$uri/ @rewrite;
      }

      location @rewrite {
	rewrite ^/(.*)\$ /index.php;
      }

     location ^~ /maintenance/ {
	return 403;
     }

    location ~ \.php\$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
         include fastcgi_params;
    }
}
EOF
```

8. Habilite o Server Name do MediaWiki e desabilite a página default removendo o link simbólico do Virtual Server Default do diretório /etc/nginx/sites-enabled:

```sh
sudo ln -s /etc/nginx/sites-available/mediawiki /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo nginx -s reload
```

9. Restart Nginx HTTP Server:

```sh
sudo systemctl restart nginx.service
```

**Extras:**

Após a configuração você pode adicionar um certificado habilitando HTTPS na confinguração dessa wiki com base no certbot e nos ceritficados assinados pelo Lets Encripyt, leia a documentação a respeito e teste o processo por sua conta:

[certbot instructions - Nginx on Ubuntu 18.04 LTS (bionic)](https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx.html)

> Leia as instruções da documentação com cuidado e utilize a opção "--staging" na instalação do certificado já que trata-se de um lab e nçao um ambiente de produção.

---


## Material de Referência:

Este laboratório foi adptado a partir do tutorial da página websiteforstudents:

* [Install MediaWiki On Ubuntu 18.04 LTS With Nginx, MariaDB And PHP 7.1 Supports](https://websiteforstudents.com/install-mediawiki-on-ubuntu-18-04-lts-beta-with-nginx-mariadb-and-php-7-1-supports/)

* [NGINX Wiki FastCGI Example](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)

----

**Free Software, Hell Yeah!**
