
# Instalação e Configuração Básica:

> Neste laboratório o sistema operacional utilizado no processo de instalação será o Centos na versão 7, observações sobre a instalação e configuração na família Debian foram adicionados ao conteúdo no decorrer dos passos.

---

O procsso de instalação do Nginx é simples, portanto utilizaremos a documentação oficial do projeto:

Documentação base para o processo de instalação da versão Opensource:
[Installing NGINX Open Source](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/);

* Esta documentação também inclui detalhes sobre a instalação usando a Família Debian

**Importante:**

Uma boa dica sobre o proceso de instalação é que em muitos casos utilizar o repositório oficial é uma alternativa que lhe permitirá obter a versão mais recente da aplicação;

Por exemplo, no processo de instaçaão do nginx utilize a seção: [Installing a Prebuilt CentOS/RHEL Package from the Official NGINX Repository](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#installing-a-prebuilt-centos-rhel-package-from-the-official-nginx-repository)

Neste exemplo a instalação será feita utilizando o Centos na versão 7 e um repositório oficial do Nginx:

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
EOF
```

Em seguida atualize o repositório e faça a instalação do Nginx:

```sh
sudo yum update
sudo yum install nginx -y
```


Em ambos os casos após a instalação o daemon será entregue no systemD, ao finalizar o processo inicie o nginx e verifique o conteúdo default exibido na página 80:

```sh
sudo systemctl start nginx
```

O servidor exibirá uma página estática similar ao modelo abaixo:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-004.png)


Ao final do processo instale algumas ferramentas auxiliares para os testes que seguirão:

```sh
sudo yum install epel-release wget vim zip zip unzip -y
```

---

# Exibindo conteúdo estático no Nginx:

Em nossos primeiros testes utilizaremos os [templates de CSS fornecidos pels paǵina w3schol](https://www.w3schools.com/w3css/w3css_templates.asp):

O processo para entrega de conteúdo estático no Nginx é similar ao modelo descrito em aulas anteriores com Apache, respeitando as diferenças referentes a diretórios e arquivo de configuração;

No centos procure pelo diretório de configuração do nginx de acordo com a árvore abaixo:

```sh
/etc/nginx/
├── conf.d
│   └── default.conf
├── default.d
├── fastcgi_params
├── koi-utf
├── koi-win
├── mime.types
├── modules -> ../../usr/lib64/nginx/modules
├── nginx.conf
├── scgi_params
├── uwsgi_params
└── win-utf
```

A configuração default parte do arquivo **nginx.conf** que referencia os arquivos criados no diretório **/etc/nginx/conf.d/**.

Este é um [exemplo do arquivo default.conf](https://github.com/fiapsistemaslinux/apostila/raw/master/content/nginx/install/default.conf) entregue na versão 1.17 do nginx na instalação na Família RedHat Centos7;

**Criando uma configuração para entrega de conteúdo estático:**

1. Crie o diretório conforme indicado na instrução "root" do arquivo de configuração:

```sh
sudo mkdir -p /usr/share/nginx/fiapdev/public
```

2. Para este teste utilizaremos templates criados [a partir desta página](https://w3cssthemes.com/):

```sh
wget https://github.com/W3CSSThemes/W3CSS-Cafe/archive/master.zip \
&& sudo unzip master.zip -d /usr/share/nginx/fiapdev/public \
&& rm -f master.zip
#
wget https://github.com/W3CSSThemes/W3CSS-Pizza-Restaurant/archive/master.zip \
&& sudo unzip master.zip -d /usr/share/nginx/fiapdev/public \
&& rm -f master.zip
#
ls -l /usr/share/nginx/fiapdev/public/*
```

3. Acesse o diretório de configuração do nginx e substitua o arquivo default:

```sh
sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.example
```

4. Antes de iniciarmos a configuração do mapeamento de conteúdo no nginx defina quais os nomes de domínio respectivos para cada página:

**Dica: Para a primeira página sugiro algo relacionado a café e para a segunda página sugiro algo relacionado a pizzas :p

```sh
export DOMAIN_1='coffepage'
export DOMAIN_2='hotpizza'
```

*A ideia de definir variaveis é unicamente utilizada para agilizar o processo de configuração*

5. Em seguida crie um novo arquivo de acordo com o exemplo abaixo:

```sh
cat <<EOF | sudo tee /etc/nginx/conf.d/coffepage.conf
server {

        root /usr/share/nginx/fiapdev/public/W3CSS-Cafe-master;
        index index.html index.htm;

        server_name ${DOMAIN_1}.fiapdev.com;

        location / {

        default_type "text/html";
        try_files \$uri.html \$uri \$uri/ =404;
        }
}
EOF
```

```sh
cat <<EOF | sudo tee /etc/nginx/conf.d/pizzapage.conf
server {

        root /usr/share/nginx/fiapdev/public/W3CSS-Pizza-Restaurant-master;
        index index.html index.htm;

        server_name ${DOMAIN_2}.fiapdev.com;

        location / {

        default_type "text/html";
        try_files \$uri.html \$uri \$uri/ =404;
        }
}
EOF
```

6. Após finzalizar a configuração é possível validar o carregamento utilizando a flag "-t" (test configuration and exit) do nginx:

```sh
sudo nginx -t
```

Após a validação carregue as novas configurações:

```sh
sudo nginx -s reload
# ou
sudo systemctl reload nginx
```

7. Para testar as novas pagínas utilizando um Browser é necessário configurar um apontamento de DNS utilizando o arquivo hosts ou possuir um endereço DNS válido;

8. A partir do terminal de comandos é possível executar testes utilizando o comando curl, neste cenário ao construir a requisição um Header com o Host de destino pode ser inserido, como no exemplo abaixo:

Se estiver em uma núvem AWS proceda da seguinte forma:

```sh
export PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
#
curl -v -H 'Host: '"$DOMAIN_1"'.fiapdev.com' http://${PUBLIC_IP}
curl -v -H 'Host: '"$DOMAIN_2"'.fiapdev.com' http://${PUBLIC_IP}
```

Em ambientes virtualizados você provavelmente utilizará o endereço ip da maquina virtual, neste cenário vocẽ pode utilizar algo similar ao comando abaixo:

```sh
PUBLIC_IP=$(hostname -I | awk '{print $1}')
#
curl -v -H 'Host: '"$DOMAIN_1"'.fiapdev.com' http://${PUBLIC_IP}}
curl -v -H 'Host: '"$DOMAIN_2"'.fiapdev.com' http://${PUBLIC_IP}
```
---

## Deploy de certificado HTTPS com CA válida:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/tls-1.png)


Certificados criptografados são utilizados na criptografia da conexão entre clientes e servidores de conteúdo, a segurança em sua aplicação se da tanto pelo uso de criptografia no tráfego quanto pela confirmação de identidade, esta segunda parte está diretamente ligada ao uso de uma CA, uma autoridade certificadora válida responsável pela checagem e confirmação dos dados usados na criação do certificado bem como sua origem.

## Lets Encrypt

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-005.png)

O Lets Encrypt é um projeto gratuito que fornece um meio para instalação de um certificado usando uma CA válida sem que seja necessário atuar a partir de uma autoridade certificadora.

### Parte 1 — Instalando o cliente do Let's Encrypt:

Instale o Certbot uma solução utilizada para configuração automática de certificados no Nginx usando o Lets Encrypt como uma CA.

```sh
sudo yum install certbot-nginx
```

### Parte 2 — Configurando o Certificado:

Com base na configuração anterior faça a solicitação do certificado:

```sh
sudo certbot --nginx -d ${DOMAIN_1}.fiapdev.com -d ${DOMAIN_2}.fiapdev.com --staging
```

> O Certbot pode configurar automaticamente o SSL para o Nginx, mas ele precisa ser capaz de encontrar o bloco de servidor correto na sua configuração. Ele faz isso procurando o parametro *server_name* que corresponde ao domínio para o qual você está solicitando um certificado.

***Importante***:

- Para que o teste funcione é necessário que o dominio especificado seja valido e por tanto já tenha DNS totalmente configurado;

- No processo de instalação você será questionado em um processo passo-a-passo sobre opções de configurações do certificado, além do email você deverá escolher entre habilitar http e https ou o redirecionamento automático de páginas para https, geralmente a opção mais segura.

- Nesta instalação utilizamos a opção "--staging" responsável pela configuração do certificado utilizando uma C.A. de testes ou seja inválida em relação a checagem feita pelo navegador, em um ambiente de produção a mesma configuração pode ser executada sem este parâmetro para criar um certificado válido, nestes casos é possível verificar o status de sua conexão/certificado a partir do [sslabs](https://www.ssllabs.com/ssltest);

---

### Material de Referência:

Este laboratório foi criado com base em um tutorial publicdo por [Mitchell Anicas]

- [How To Secure Nginx with Let's Encrypt on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-centos-7)

- [Documentação Oficial do Nginx](https://docs.nginx.com/nginx/admin-guide/)

---

**Free Software, Hell Yeah!**
