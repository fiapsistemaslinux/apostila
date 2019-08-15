# Configurando um proxy reverso com Nginx

---

## Criando uma aplicação (para implantação "por trás" do proxy

Neste teste utilizaremos uma aplicação Python simples que funcionará como o endpoint configurado para receber as requisições repassadas pelo servidor nginx.

1. Instale as ferramentas de apoio necessárias: 

```sh
$ sudo yum install git curl epel-release python-pip -y
```

2. Faça um clone do repositório base e inicie a aplicação python de backend:

```sh
$ git clone https://github.com/helcorin/python-cicd-buzz
$ cd python-cicd-buzz
$ pip install -r requeriments.txt
$ python app.py & 
```

> Como trata-se de um exemplo alguns cuidados importantes foram deixados de lado como o uso de um formato estável para execução com base na configuração do serviço via systemd ou containers ou mesmo como o uso de virtualenv ao invés da instalação de dependências na raiz, o resultado final será a entrega da aplicação na porta 5000 do localhost, essa aplicação será roteada a partir da configuração a seguir executada no nginx.

---

## Instalação do Nginx:

O procsso de instalação do Nginx é simples, portanto utilizaremos a documentação oficial do projeto:

Documentação base para o processo de instalação da versão Opensource:
[Installing NGINX Open Source](https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/);

* Esta documentação também inclui detalhes sobre a instalação usando a Família Debian

1. Primeiro defina o nome de sua nova api (este nome será usado na composição do endereço de DNS):

```sh
export DOMAIN_API='pyapi'
```

2. Crie um arquivo de configuração conforme abaixo:


```sh
cat <<EOF | sudo tee /etc/nginx/conf.d/api.conf

server {
        listen 80;

        server_name ${DOMAIN_API}.fiapdev.com;

        location / {
            proxy_pass http://localhost:5000;
        }
}
EOF
```

Neste exemplo a configuração entregue refere-se a um proxy reverso (instrução proxy_pass) que enviará as requisições recebidas a porta 5000 (porta da aplicação python usada neste teste);

3. Valide a configuração e em seguida inicie o nginx:


```sh
sudo nginx -t
```

Após a validação carregue as novas configurações:

```sh
sudo nginx -s reload
# ou
sudo systemctl start nginx
```

---

## Material de Referência:

* [NGINX Documentation](https://nginx.org/en/docs/)
* [Artigo: Use NGINX as a Reverse Proxy](https://www.linode.com/docs/web-servers/nginx/use-nginx-reverse-proxy/)

----

**Free Software, Hell Yeah!**
