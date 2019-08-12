
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

Em ambos os casos após a instalação o daemon será entregue no systemD, ao finalizar o processo inicie o nginx e verifique o conteúdo default exibido na página 80:

```sh
systemctl start nginx
```

O servidor exibirá uma página estática similar ao modelo abaixo:

![alt tag](https://github.com/fiapsistemaslinux/apostila/raw/master/images/nginx-004.png)


Ao final do processo instale algumas ferramentas auxiliares para os testes que seguirão:

```sh
yum install epel-release wget vim zip zip unzip -y
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

1. Acesse o diretório de configuração do nginx e substitua o arquivo default:

```sh
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.example
```

2. Em seguida crie um novo arquivo de acordo com o exemplo abaixo:

```sh
cat <<EOF | sudo tee /etc/nginx/conf.d/static.conf
server {

        listen 80;

        root /usr/share/nginx/fiapdev/public;
        index index.html index.htm;

        server_name fiap.io;

        location / {

        default_type "text/html";
        try_files $uri.html $uri $uri/ =404;
        }
}
EOF
```

3. Crie o diretório conforme indicado na instrução "root" do arquivo de configuração:

```sh
mkdir -p /usr/share/nginx/fiapdev/public/
```

4. Para este teste escolha um dos templates [a partir desta página](https://w3cssthemes.com/), escolha a opção **free** e em seguida faça o Download e descompactação do arquivo no diretório "/usr/share/nginx/fiap.io/public/" remova qualquer subpasta no processo.

5. Finalmente carregue as configurações novas no nginx:

```sh
sudo systemctl reload nginx
```

----

**Free Software, Hell Yeah!**
