![alt tag](https://raw.githubusercontent.com/fiap2trc/services/apache/lab-2.1/lab-logo.png)

# Laboratório Pŕatico: Migração de um site para Azure

**Descrição:** Neste cenário faremos a migração do site criado em VM para ambiente Azure utiizando scp;

## 1 - Estabelecendo conexão com a instancia criada na azure

Para execução de transferência via ssh é necessário um usuário válido, em nosso cenário por questões de segurança utilizaremos chaves RSA com criptografia assimétrica:

**1.1:** Crie uma nova chave na VM rodando ubuntu:

```sh
ssh-keygen -t rsa -b 4096

Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase): 
...

```

Verifique a chave publicada criada:

```sh
cat /root/.ssh/id_rsa.pub
```

**1.2:** Não é necessário cadastrar uma frase passe mas você pode utilizar esse recurso se quiser, como não temos uma conta local remotamente não será possível executar o envio utilizando o ssh-copy-id, logo adicionaremos a chave publica manualmente na instância: 

***Na instância criada na azure crie um diretório de chaves para o usuário root:***

Crie o diretório .ssh

```sh
su:** root
mkdir ~/.ssh
```

Crie o arquivo authorized_keys:

```sh
touch ~/.ssh/authorized_keys
```

Faça a restrição nas permissões de acesso a pasta e ao arquivo:

```sh
chmod 600 ~/.ssh -R
```

**1.3:** Abra o arquivo de chaves criado e em seguida adicione a chave criada para acesso remoto:

```sh
vim ~/.ssh/authorized_keys
```

**1.4:** Cheque o funcionamento da chave executando um o acesso remoto a partir da VM rodando ubuntu:

```sh
ssh -l root <IP-INSTANCIA-AZURE>
```

---

## 2 - Instalando os pacotes necessários:

**2.1:** Com acesso configurado instale os pacotes necessários para o apache:

```sh
sudo apt-get update
sudo apt-get install apache2 curl
```

---

## 3 - Enviando os arquivos para o novo destino:

**3.1:** Com as credenciais para acesso remoto criadas utilizaremos a função scp do ssh para transferência de arquivos:

```sh
scp /etc/apache2/sites-available/001-cloud-ssl.conf <IP-INSTANCIA-AZURE>:/etc/apache2/sites-available/
scp -r /etc/ssl/private/apache-selfsigned.* <IP-INSTANCIA-AZURE>:/etc/ssl/private/
```

**3.2:** Para copiar o template utilizado no site podemos utilizar a opção "-r" do scp, ou neste caso para economai de banda vamos otimizar o tamanho do conteúdo a ser copiado utilizando o tar com o padrão de compressão bzip2:

```sh
cd /var/www/html
tar -cvjf cloud.tar.bz2 clould

cloud/
cloud/fonts/
cloud/fonts/glyphicons-halflings-regular.svg
cloud/fonts/glyphicons-halflings-regular.ttf
...

```

Em seguida envie o arquivo compresso via scp e extraia no host de destino:

```sh
scp cloud.tar.bz2 <IP-INSTANCIA-AZURE>:/var/www/html/
```

---

## 4 - Configurando o serviço e subindo o apache

**4.1:** Para configurar o serviço na instancia criada extraia o arquivo criado:

```sh
ssh <IP-INSTANCIA-AZURE>
tar -xvf /var/www/html/cloud.tar.bz2 -C /var/www/html/
```

**4.2:** Desabilite o virtualhost default:

```sh
a2dissite 000-default
```

**4.3:** Habilite o novo virtualhost:

```sh
a2enssite 001-cloud-ssl
```

**4.4:** Habilite os modulos para rewrite de requisições e ssl:

```sh
a2enmod ssl
a2enmod rewrite
```

**4.5:** Finalmente reinicialize o serviço para testar a nova configuração:

```sh
systemctl restart apache2
```

